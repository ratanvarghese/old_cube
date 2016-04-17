require("base")
require("pt")
require("stage")
require("proto")
require("terrain")

local ter_pt_max = pt.at{x=pt.max.x, y=pt.max.y, z=pt.heights.terrain}
local ter_pt_min = pt.at{x=pt.min.x, y=pt.min.y, z=pt.heights.terrain}
stgen = {}

--Basic "stages"
function stgen.g_mono(st, tername)
    local st = st or stage.new()
    local tername = tername or "floor"
    for p in pt.all_positions{min=ter_pt_min, max=ter_pt_max} do
        stage.add_ent(st, proto.clone_of(tername), p)
    end
    return st
end

function stgen.g_rand(st, ter_list)
    local st = st or stage.new()
    local ter_list = ter_list or {"floor", "wall"}
    local ter_count = #ter_list
    for p in pt.all_positions{min=ter_pt_min, max=ter_pt_max} do
        local tername = ter_list[rng.dice(1, #ter_list)]
        stage.add_ent(st, proto.clone_of(tername), p)
    end
    return st
end

--Cellular automata
function stgen.g_cell(st, ter_list, cycles, crit_neighbor)
    local ter_list = ter_list or {"floor", "wall"}
    st = stgen.g_rand(st, ter_list)
    local cycles = cycles or 5
    local crit_neighbor = crit_neighbor or 4
    
    local function neighbor_is_crit(ent, targ_name)
        if pt.is_edge(ent.pt) then
            return false
        end
        local count = 0
        local off_one = pt.at{x=1, y=1, z=0}
        local min = ent.pt - off_one
        local max = ent.pt + off_one
        if min <= ter_pt_min then min = ter_pt_min end
        if max >= ter_pt_max then max = ter_pt_max end
        for p in pt.all_positions{min=min, max=max} do
            assert(ent.stage[p], "missing " .. tostring(p))
            if ent.stage[p].name == targ_name then
                count = count + 1
            end
        end
        return count > crit_neighbor
    end

    local new_st = nil
    for i=0,cycles do
        new_st = stage.new()
        for p in pt.all_positions{min=ter_pt_min, max=ter_pt_max} do
            local tername = ter_list[2]
            if neighbor_is_crit(st[p], tername) then
                tername = ter_list[1]
            end
            stage.add_ent(new_st, proto.clone_of(tername), p)
        end
        st = new_st
    end
    return new_st or st or stgen.g_rand(ter_list)
end
