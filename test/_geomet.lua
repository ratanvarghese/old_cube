require("geomet")

mb = pt.at{x=20,y=20}
vlist = {
    pt.at{x=1, y=1},
    pt.at{x=1, y=9},
    pt.at{x=5, y=9},
    pt.at{x=7, y=11},
    pt.at{x=9, y=1}
}
--[[
vlist = {
    pt.at{x=1, y=1},
    pt.at{x=1, y=15},
    pt.at{x=3, y=15}
}
--]]

L = geomet.polygon(vlist, 0)
for p in pt.all_positions{min=pt.at{x=0, y=0}, max=mb} do
    if L[pt.hash(p)] then
        io.write(".")
    else
        io.write("#")
    end

    if p.x == mb.x then
        io.write("\n")
    end

end
