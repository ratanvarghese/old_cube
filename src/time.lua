local function create_time_table()
    local result = {}
    result.tick = 0
    result.tick_max = 20
    result.add_list = {} --ordered
    result.add_set = {} --unordered
    result.remove_set = {} --unordered
    result.all_undos = {} --ordered
    result.all_routines = {} --ordered
    return result
end

local default_time = create_time_table()

local function current(time_table)
    if not time_table then time_table = default_time end
    return time_table.tick
end

local function add(routine, time_table)
    --need ordered addition, unordered checking
    --an added entity can change behavior of existing entities
    if not time_table then time_table = default_time end
    assert(type(routine) == "thread", "Time: invalid add")
    table.insert(time_table.add_list, routine)
    time_table.add_set[routine] = true
end

local function remove(routine, time_table)
    --only unordered checking needed
    --once removal request is sent, entity is inactive
    assert(type(routine) == "thread", "Time: invalid remove")
    if not time_table then time_table = default_time end
    time_table.remove_set[routine] = true
end

local function loop(go_func, time_table)
    if not time_table then time_table = default_time end
    if not go_func then
        go_func = function()
            return time_table.tick < time_table.tick_max
        end
    end
    
    local function update_routine_list(time_table)
        for i,v in ipairs(time_table.add_list) do
            table.insert(time_table.all_routines, v)
        end

        for i=1,#time_table.all_routines do
            local v = time_table.all_routines[i]
            if time_table.remove_set[v] then
                table.remove(time_table.all_routines, i)
            end
        end
    
        time_table.remove_set = {}
        time_table.add_set = {}
        time_table.add_list = {}
    end

    update_routine_list(time_table)

    local continue = true
    while true do
        time_table.all_undos[time_table.tick] = {}

        for i,v in ipairs(time_table.all_routines) do
            if not go_func() then
                continue = false
                break
            end

            local fail1 = coroutine.status(v) == "dead"
            local fail2 = time_table.remove_set[v]  
            if not fail1 and not fail2 then
                local status, undo = coroutine.resume(v)
                assert(status, undo) --undo would hold error info
                assert(type(undo)=="function", "Time: non-function undo")
                table.insert(time_table.all_undos[time_table.tick] , undo)
            end
        end

        if not continue then
            break
        end
        
        update_routine_list(time_table)
        time_table.tick = time_table.tick + 1
    end
end

local function reverse(dest_tick, time_table)
    if not time_table then time_table = default_time end
    dest_tick = math.tointeger(dest_tick)

    assert(dest_tick >= 0, "Time: attempt to travel to negative time")
    assert(dest_tick < time_table.tick, "Time: future travel in reverse")

    for t=time_table.tick,dest_tick,-1 do
        if time_table.all_undos[t] then
            for i,v in ipairs(time_table.all_undos[t]) do
                v()
            end
            time_table.all_undos[t] = nil
        end

        if t ~= dest_tick then
            time_table.tick = time_table.tick - 1
        end
    end
end

time = {
    current = current,
    add = add,
    remove = remove,
    loop = loop,
    reverse = reverse,
}
