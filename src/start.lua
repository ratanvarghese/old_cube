require("pt")
require("config")
require("control")
require("monst")
require("terrain")

err = config.readfile()
if err then
    userio.message(err)
end

rng.init(rng.metaseed)

stage = {}
for p in pt.all_positions{max=pt.max*pt.at{x=1,y=1}} do
    local terrain_name = "floor"
    if rng.coin() then terrain_name = "wall" end
    stage[tostring(p)] = proto.clone_of(terrain_name)
end


center = pt.at{x=10, y=10, z=pt.heights.standing}
dude = proto.clone_of("human")
function dude.move_to(p)
    if pt.valid_position(p) then
        stage[tostring(dude.position)] = nil
        dude.position = p
        center = p
        stage[tostring(p)] = dude
        return true
    else
        return false
    end
end
dude.move_to(center)

main_control = {"main", "direction"}
userio.display(stage, center)
while true do
    local input = userio.input(main_control, true, "> ")
    local mv = pt.direction[input]
    if mv then
        if mv == pt.direction.up then
            userio.message("You jump!")
        elseif mv == pt.direction.down then
            userio.message("You crouch...")
        elseif dude.move_to(mv + dude.position) then
            userio.display(stage, center)
        else
            userio.message("Bump!")
        end
    elseif input == "quit" then
        break
    else
        userio.message("Invalid input")
    end
end
