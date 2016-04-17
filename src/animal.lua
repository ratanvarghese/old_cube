require("mind")
require("pt")
require("stage")

local function animal_logic(b, m)
    return function()
        while true do
            local vector = pt.direction.south
            local opp = pt.direction.north
            local went_down = stage.mv_ent(b.stage, b, vector + b.pt)
            if not went_down then
                vector = pt.direction.north
                opp = pt.direction.south
                stage.mv_ent(b.stage, b, vector + b.pt)
            end
            coroutine.yield(function()
                stage.mv_ent(b.stage, b, opp + b.pt)
            end) 
        end
    end
end

function mind.animal(b)
    b.mind = {}
    b.mind.free_will = 0
    b.mind.co = coroutine.create(animal_logic(b, b.mind))

    b.mind.body = b
    return b
end
