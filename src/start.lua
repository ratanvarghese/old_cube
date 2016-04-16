require("pt")
require("config")
require("terrain")
require("stage")
require("player")
require("time")

err = config.readfile()
if err then
    userio.message(err)
end

rng.init(rng.metaseed)

my_stage = stage.new()
for p in pt.all_positions{max=pt.max*pt.at{x=1,y=1}} do
    local terrain_name = "floor"
    if rng.coin() then terrain_name = "wall" end
    stage.add_ent(my_stage, proto.clone_of(terrain_name), p)
end

pbody = player.init()
stage.add_ent(my_stage, pbody, pt.at{x=10, y=10, z=pt.heights.stand})
userio.display(my_stage, pbody.pt)

time.add(player.mind.co)
time.loop(function() return player.continuing end)
time.reverse(0)
