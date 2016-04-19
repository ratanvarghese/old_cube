require("pt")
require("base")

stage = {}
local protostage = {}
local stage_mt = {
    __index = function(t, k)
        if pt.valid_position(k) then
            return rawget(t, pt.hash(k))
        else
            return nil
        end
    end,
    __newindex = function(t, k, v)
        if pt.valid_position(k) then
            rawset(t, pt.hash(k), v)
        else
            rawset(t, k, v)
        end
    end,
}

function stage.new()
    local res = base.copy(protostage)
    setmetatable(res, stage_mt)
    return res
end

function stage.is_stage(t)
    return getmetatable(t) == stage_mt
end

function stage.add_ent(cur_stage, ent, pos)
    if cur_stage[pos] then
        return false
    else
        cur_stage[pos] = ent
        ent.pt = pos
        ent.stage = cur_stage
        return true
    end
end

function stage.rem_ent(cur_stage, ent)
    cur_stage[ent.pt] = nil
    ent.pt = nil
    ent.stage = nil
end

stage.mverr = {invalid_pos = 1, occupied = 2} 
function stage.mv_ent(cur_stage, ent, new_pos)
    if pt.valid_position(new_pos) then
        cur_stage[ent.pt] = nil
        cur_stage[new_pos] = ent
        ent.pt = new_pos
        return true
    else
        return false, stage.mverr.invalid_pos
    end
end
