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

controls = {
    ["k"] = pt.at{y=-1},
    ["j"] = pt.at{y=1},
    ["h"] = pt.at{x=-1},
    ["l"] = pt.at{x=1}
}

s = " "
userio.display(stage, center)
while s ~= "q" do
    s = userio.get_string()
    if controls[s] then
        nu_p = controls[s] + dude.position
        if dude.move_to(nu_p) then
            userio.display(stage, center)
        end
    end
end
