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

my_stage = stgen.g_cell(nil, 4, 3)

pbody = player.init()
stage.add_ent(my_stage, pbody, pt.at{x=10, y=10, z=pt.heights.stand})
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
