require("pt")
require("config")
require("control")
require("monst")
require("terrain")
require("stage")
require("player")
require("mind")
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
    my_stage[p] = proto.clone_of(terrain_name)
end


center = pt.at{x=10, y=10, z=pt.heights.standing}
pbody = player.init_body()
mind.player(pbody)
player.put_on_stage(my_stage, center)

time.add(player.mind.co)
time.loop(function() return player.continuing end)
