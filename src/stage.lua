require("pt")
require("base")

local protostage = {}

local stage_mt = {
    __index = function(t, k)
        return rawget(t, tostring(k))
    end,
    __newindex = function(t, k, v)
        if protostage[k] then
            rawset(t, k, v)
        elseif pt.valid_position(k) then
            rawset(t, tostring(k), v)
        else
            error("Attempt to add invalid key to stage: " .. tostring(k))
        end
    end,
}

stage = {}

function stage.new()
    local res = base.copy(protostage)
    setmetatable(res, stage_mt)
    return res
end

function stage.is_stage(t)
    return getmetatable(t) == stage_mt
end

function stage.mv(stage, ent, old_pt, new_pt, ent_idx)
    if stage[old_pt] == ent then
        stage[old_pt] = nil
        stage[new_pt] = ent
        if ent_idx then
            ent[ent_idx] = new_pt
        end
    else
        error("Wrong initial position: " .. tostring(old_pt))
    end
end
