require("pt")
dude = {symbol="@"}
phalanx_side = 5
center = pt.at{x=10, y=10, z=pt.heights.standing}
start = center - pt.at{x=phalanx_side, y=phalanx_side, z=0}

army = {}
for p in pt.all_positions{min=start, max=center} do
    army[tostring(p)] = dude
end

userio.display(army, center)
userio.get_string()
