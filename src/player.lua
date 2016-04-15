require("pt")
require("userio")
require("control")
require("stage")
require("mind")
require("monst")

player = {}
player.continuing = true

function player.init_body()
    player.body = proto.clone_of("human")
    return player.body
end

local function player_logic()
    local main_control = {"main", "direction"}
    local body = player.body

    local function move_action(vector)
        if vector == pt.direction.up then
            userio.message("You jump!")
        elseif vector == pt.direction.down then
            userio.message("You crouch...")
        elseif body.stage:mv_ent(body, vector + body.pt) then
            userio.display(body.stage, body.pt)
            return function()
                local rev_vector = pt.at{x=-1, y=-1, z=-1}
                body.stage:mv_ent(body, (rev_vector * vector) + body.pt)
                userio.display(body.stage, body.pt)
            end 
        else
            userio.message("Bump!")
        end
        return function() end
    end

    while true do
        local input = userio.input(main_control, true, "> ")
        local vector = pt.direction[input]
        local reversal = function() end
        if vector then
            reversal = move_action(vector)
        elseif input == "quit" then
            userio.message("Goodbye")
            player.continuing = false
        else
            userio.message("Invalid input")
        end
        coroutine.yield(reversal)
    end
end

function mind.player(body)
    body.mind = {}
    body.mind.free_will = 100
    body.mind.co = coroutine.create(player_logic)
    
    body.mind.body = body
    player.mind = body.mind
end
