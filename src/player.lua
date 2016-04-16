require("pt")
require("userio")
require("control")
require("stage")
require("monst")

player = {}
player.continuing = true

local function player_logic(b, m)
    local actions = {}

    function actions.move(b, vector)
        if vector == pt.direction.up then
            userio.message("You jump!")
        elseif vector == pt.direction.down then
            userio.message("You crouch...")
        elseif stage.mv_ent(b.stage, b, vector + b.pt) then
            userio.display(b.stage, b.pt)
            return function()
                local rev_vector = pt.at{x=-1, y=-1, z=-1}
                stage.mv_ent(b.stage, b, (rev_vector * vector) + b.pt)
                userio.display(b.stage, b.pt)
            end 
        else
            userio.message("Bump!")
        end
    end

    function actions.quit()
        userio.message("Goodbye")
        player.continuing = false
    end

    function actions.help()
        userio.message("Maybe laterrrrrr....")
    end

    return function()
        local main_control = {"main", "direction"}
        while true do
            local input = userio.input(main_control, true, "> ")
            local reverse = false
            if actions[input] then
                reverse = actions[input]()
            elseif pt.direction[input] then
                reverse = actions.move(b, pt.direction[input])
            end
            coroutine.yield(reverse or function() end)
        end
    end
end

function player.init()
    local b = proto.clone_of("human")
    player.body = b    

    b.mind = {}
    b.mind.free_will = 100
    b.mind.co = coroutine.create(player_logic(b, mind))
    
    b.mind.body = b
    player.mind = b.mind

    return b
end
