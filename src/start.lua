require("pt")

rng.init(rng.metaseed)

stage = {}
for p in pt.all_positions{max=pt.max*pt.at{x=1,y=1}} do
    c = "."
    if rng.coin() then c = "#" end
    stage[tostring(p)] = {symbol=c}
end


center = pt.at{x=10, y=10, z=pt.heights.standing}
dude = {symbol="@"}
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

userio.display(stage, center)
keep_going = true
while keep_going do
    input = userio.input(userio.controls.main, true, "> ")
    if pt.is_pt(input) then
        if dude.move_to(input + dude.position) then
            userio.display(stage, center)
        else
            userio.message("Bump!")
        end
    elseif input == "quit" then
        keep_going = false
    else
        userio.message("Invalid input")
    end
end
