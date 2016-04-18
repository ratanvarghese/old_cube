require("base")
require("pt")
require("stage")
require("proto")
require("terrain")

local ter_pt_max = pt.at{x=pt.max.x, y=pt.max.y, z=pt.heights.terrain}
local ter_pt_min = pt.at{x=pt.min.x, y=pt.min.y, z=pt.heights.terrain}

--Primitive generators
local function pg_mono(num)
    local num = num or 1
    local st = stage.new()
    for p in pt.all_positions{min=ter_pt_min, max=ter_pt_max} do
        st[p] = num
    end
    return st
end

local function pg_rand(max)
    local max = max or 2
    local st = stage.new()
    for p in pt.all_positions{min=ter_pt_min, max=ter_pt_max} do
        st[p] = rng.dice(1, max)
    end
    return st
end

local function pg_cell(max, cycles, crit_neighbor)
    local max = max or 2
    local cycles = cycles or 4
    local crit_neighbor = crit_neighbor or 3
    local old_st = pg_rand(max)
    local new_st = stage.new()

    local function new_cell(p, targ, alt)
        local count = 0
        local off_one = pt.at{x=1, y=1, z=0}
        for p in pt.all_positions{min=p-off_one, max=p+off_one} do
            if old_st[p] == targ then
                count = count + 1
                if count > crit_neighbor then
                    return alt
                end
            end
        end
        return targ
    end

    for i=0,cycles do
        for p in pt.all_positions{min=ter_pt_min, max=ter_pt_max} do
            new_st[p] = new_cell(p, max, 1)
        end
        old_st, new_st = new_st, old_st
    end

    return old_st
end

--Primitive to public
local function primitive_to_public(st, ter_list)
    for p in pt.all_positions{min=ter_pt_min, max=ter_pt_max} do
        local n = st[p]
        st[p] = nil
        stage.add_ent(st, proto.clone_of(ter_list[n]), p)
    end
    return st
end

--Public
stgen = {}
function stgen.g_mono()
    local ter_list = ter_list or {"floor", "wall"}
    local st = pg_mono(#ter_list)
    return primitive_to_public(st, ter_list)
end

function stgen.g_rand()
    local ter_list = ter_list or {"floor", "wall"}
    local st = pg_rand(#ter_list)
    return primitive_to_public(st, ter_list)
end

function stgen.g_cell(ter_list, cycles, crit_neighbor)
    local ter_list = ter_list or {"floor", "wall"}
    local st = pg_cell(#ter_list, cycles, crit_neighbor)
    return primitive_to_public(st, ter_list)
end
