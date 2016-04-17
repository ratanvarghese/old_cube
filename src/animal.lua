require("mind")
require("pt")
require("stage")

local function animal_logic(b, m)
    return function()
        local is_up = rng.coin()
        while true do
            local vector = pt.direction.south
            local opp = pt.direction.north
            if is_up then vector, opp = opp, vector end
            is_up = not is_up
            stage.mv_ent(b.stage, b, vector + b.pt)
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
