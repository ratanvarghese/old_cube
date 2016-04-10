require("_common")
require("proto")

results = {}

test1 = "Error on missing name"
results[test1] = not pcall(function() proto.register() end)

test2 = "Simple register + clone"
goblin_proto = {
    name = "goblin",
    symbol = "o",
}
proto.register(goblin_proto)
my_goblin = proto.clone_of("goblin")
results[test2] = my_goblin.symbol == goblin_proto.symbol

test3 = "Inherit data"
orc_proto = {
    super = "goblin",
    name = "orc",
}
proto.register(orc_proto)
my_orc = proto.clone_of("orc")
results[test3] = my_orc.symbol == goblin_proto.symbol

test4 = "Run clone_init when cloning"
results[test4] = true
clone_count = 0
dog_proto = {
    name = "dog",
    clone_init = function()
        clone_count = clone_count + 1
    end,
}
proto.register(dog_proto)
if clone_count ~= 0 then results[test4] = false end
dog1 = proto.clone_of("dog")
if clone_count ~= 1 then results[test4] = false end
dog2 = proto.clone_of("dog")
if clone_count ~= 2 then results[test4] = false end

test5 = "clone_init arguments"
results[test5] = true
clone_count = 0
pitbull_hp = 30
pitbull_proto = {
    super = "dog",
    name = "pitbull",
    clone_init = function(res, p)
        p.super.clone_init(res, p)
        res.hp = pitbull_hp
    end,
}
proto.register(pitbull_proto)
pitbull1 = proto.clone_of("pitbull")
if clone_count ~= 1 then results[test5] = false end
if pitbull1.hp ~= pitbull_hp then results[test5] = false end

print_results(results, "proto")
