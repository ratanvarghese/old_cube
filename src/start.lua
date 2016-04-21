require("pt")
require("config")
require("stage")
require("stgen")
require("player")
require("proto")
require("mind")
require("animal")
require("time")
require("replay")
require("userio")

err = config.readfile()
name = userio.get_string("What's your name?")
if err then
    userio.message(err) --Not before name seek, so that error is seen!
end
replay.init(name)

local ter_pt_max = pt.at{x=pt.max.x, y=pt.max.y, z=pt.heights.terrain}
local ter_pt_min = pt.at{x=pt.min.x, y=pt.min.y, z=pt.heights.terrain}
my_stage = stgen.g_cell()
player_p = pt.at{x=10, y=10, z=pt.heights.stand}
for p in pt.all_positions{min=ter_pt_min, max=ter_pt_max} do
    if my_stage[p].symbol == "." then
        player_p = pt.at{x=p.x, y=p.y, z=pt.heights.stand}
        break
    end
end
pbody = player.init()
stage.add_ent(my_stage, pbody, player_p)
fido = mind.suits_body(proto.clone_of("dog"))
stage.add_ent(my_stage, fido, pt.at{x=12, y=10, z=pt.heights.sit})
dogley = mind.suits_body(proto.clone_of("dog"))
stage.add_ent(my_stage, dogley, pt.at{x=14, y=10, z=pt.heights.sit})

replay.add_enter_present_hook(function() userio.display(my_stage, pbody.pt)end)

time.add(player.mind.co)
time.add(fido.mind.co)
time.add(dogley.mind.co)
time.loop(function()
    userio.display(my_stage, pbody.pt)
    return player.continuing
end)
replay.save()
