require("pt")
require("stage")
require("proto")
require("terrain")

local ter_min = pt.at{x=pt.min.x, y=pt.min.y, z=pt.heights.terrain}
local ter_max = pt.at{x=pt.max.x, y=pt.max.y, z=pt.heights.terrain}

--Primitive functions: true == obstacle, false == walkable
local function pg_rand(percent_obstacle, st)
    local percent_obstacle = percent_obstacle or 50
    for p in pt.all_positions{min=ter_min, max=ter_max} do
        st[p] = rng.wcoin(percent_obstacle)
    end
    return st
end

local function pg_mono(val, st)
    for p in pt.all_positions{min=ter_min, max=ter_max} do
        st[p] = val
    end
    return st
end

local function pg_cell(st)
    local old_st = pg_rand(45, st)
    local new_st = stage.new()
    local cycles = 7

    local function new_cell(p, c)
        local obs_count1 = 0
        local obs_count2 = 0
        local off_2 = pt.at{x=2, y=2, z=0}
        local abs = math.abs
        for p2 in pt.all_positions{max=p+off_2, min=p-off_2} do
            if old_st[p2] then
                obs_count2 = obs_count2 + 1
                if abs(p2.x-p.x) <= 1 and abs(p2.y-p.y) <= 1 then
                    obs_count1 = obs_count1 + 1
                end 
            end
        end

        if c < 4 then
            return obs_count1 >= 5 or obs_count2 <= 2
        else
            return obs_count1 >= 5
        end
    end

    for c=1,cycles do
        for p in pt.all_positions{min=ter_min, max=ter_max} do
            new_st[p] = new_cell(p, c)
        end
        old_st, new_st = new_st, old_st
    end
    return old_st
end

local function pg_walk(st)
    pg_mono(true, st)
    local steps = 3600
    local startx = rng.dice(1, pt.max.x)
    local starty = rng.dice(1, pt.max.y)
    local p = pt.at{x=startx, y=starty, z=ter_max.z}
    for s=1,steps do
        st[p] = false
        while not st[p] or not pt.valid_position(p) do
            p = p + pt.at{x=rng.dice(1, 3)-2, y=rng.dice(1, 3)-2, z=0}
        end
    end
    return st
end


--topublic
local function topublic(st)
    for p in pt.all_positions{min=ter_min, max=ter_max} do
        local tername = "floor"
        if st[p] then tername = "wall" end
        st[p] = proto.clone_of(tername)
    end
    return st
end

--public
stgen = {}

function stgen.g_cell()
    return topublic(pg_cell(stage.new()))
end

function stgen.g_walk()
    return topublic(pg_walk(stage.new()))
end
