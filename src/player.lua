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

function player.put_on_stage(cur_stage, position)
    cur_stage[position] = player.body
    player.body.pt = position
    userio.display(my_stage, position)
end

local function player_logic()
    local main_control = {"main", "direction"}
    local function move_to(p)
        if pt.valid_position(p) then
            stage.mv(my_stage, player.body, player.body.pt, p, "pt")
            center = p
            return true
        else
            return false
        end
    end

    while true do
        local input = userio.input(main_control, true, "> ")
        local mv = pt.direction[input]
        if mv then
            if mv == pt.direction.up then
                userio.message("You jump!")
            elseif mv == pt.direction.down then
                userio.message("You crouch...")
            elseif move_to(mv + player.body.pt) then
                userio.display(my_stage, center)
            else
                userio.message("Bump!")
            end
        elseif input == "quit" then
            userio.message("Goodbye")
            player.continuing = false
        else
            userio.message("Invalid input")
        end
        coroutine.yield(function() end)
    end
end

function mind.player(body)
    body.mind = {}
    body.mind.free_will = 100
    body.mind.co = coroutine.create(player_logic)
    
    body.mind.body = body
    player.mind = body.mind
end
