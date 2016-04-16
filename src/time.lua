require("base")

local function create_time_table()
    local result = {}
    result.tick = 0
    result.add_list = {} --ordered
    result.add_set = {} --unordered
    result.remove_set = {} --unordered
    result.all_undos = {} --ordered
    result.all_routines = {} --ordered
    return result
end

time = {}
local default_time = create_time_table()

function time.current(time_t)
    local time_t = time_t or default_time
    return time_t.tick
end

function time.add(routine, time_t)
    --need ordered addition, unordered checking
    --an added entity can change behavior of existing entities
    local time_t = time_t or default_time
    assert(type(routine) == "thread", "Time: invalid add")
    table.insert(time_t.add_list, routine)
    time_t.add_set[routine] = true
end

function time.remove(routine, time_t)
    --only unordered checking needed
    --once removal request is sent, entity is inactive
    assert(type(routine) == "thread", "Time: invalid remove")
    local time_t = time_t or default_time
    time_t.remove_set[routine] = true
end

function time.loop(go_func, time_t)
    local function update_routine_list(time_t)
        base.join_list(time_t.add_list, time_t.all_routines)
        for i=1,#time_t.all_routines do
            if time_t.remove_set[time_t.all_routines[i]] then
                table.remove(time_t.all_routines, i)
            end
        end
    
        time_t.remove_set = {}
        time_t.add_set = {}
        time_t.add_list = {}
    end

    local time_t = time_t or default_time
    assert(type(go_func) == "function", "Missing go_func")
    update_routine_list(time_t)

    while true do
        local continue = true
        time_t.all_undos[time_t.tick] = {}
        for i,v in ipairs(time_t.all_routines) do
            continue = go_func()
            if not continue then break end

            if coroutine.status(v) == "dead" then
                time.remove(v, time_t)
            end

            if not time_t.remove_set[v] then
                local status, undo = coroutine.resume(v)
                assert(status, undo) --undo would hold error info
                assert(type(undo)=="function", "Time: non-function undo")
                table.insert(time_t.all_undos[time_t.tick] , undo)
            end
        end
        if not continue then break end
        update_routine_list(time_t)
        time_t.tick = time_t.tick + 1
    end
end

function time.reverse(dest_tick, time_t)
    local time_t = time_t or default_time
    dest_tick = math.tointeger(dest_tick)

    assert(dest_tick >= 0, "Time: attempt to travel to negative time")
    assert(dest_tick < time_t.tick, "Time: future travel in reverse")

    for t=time_t.tick,dest_tick,-1 do
        if time_t.all_undos[t] then
            for i,v in ipairs(time_t.all_undos[t]) do v() end
            time_t.all_undos[t] = nil
        end

        if t ~= dest_tick then time_t.tick = time_t.tick - 1 end
    end
end
