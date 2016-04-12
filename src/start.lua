require("pt")
require("config")
require("control")
require("monst")
require("terrain")
require("stage")

err = config.readfile()
if err then
    userio.message(err)
end

rng.init(rng.metaseed)

my_stage = stage.new()
for p in pt.all_positions{max=pt.max*pt.at{x=1,y=1}} do
    local terrain_name = "floor"
    if rng.coin() then terrain_name = "wall" end
    my_stage[p] = proto.clone_of(terrain_name)
end


center = pt.at{x=10, y=10, z=pt.heights.standing}
dude = proto.clone_of("human")
function dude.move_to(p)
    if pt.valid_position(p) then
        stage.mv(my_stage, dude, dude.pt, p, "pt")
        center = p
        return true
    else
        return false
    end
end
my_stage[center] = dude
dude.pt = center

main_control = {"main", "direction"}
userio.display(my_stage, center)
while true do
    local input = userio.input(main_control, true, "> ")
    local mv = pt.direction[input]
    if mv then
        if mv == pt.direction.up then
            userio.message("You jump!")
        elseif mv == pt.direction.down then
            userio.message("You crouch...")
        elseif dude.move_to(mv + dude.pt) then
            userio.display(my_stage, center)
        else
            userio.message("Bump!")
        end
    elseif input == "quit" then
        break
    else
        userio.message("Invalid input")
    end
end
