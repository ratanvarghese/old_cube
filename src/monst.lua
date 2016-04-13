require("proto")

proto.register{
    name = "monster",
    clone_init = function() end, --Nothing yet...
}

proto.register{
    name = "human",
    supername = "monster",
    mindname = "sentient",
    symbol = "@",
}

proto.register{
    name = "dog",
    supername = "monster",
    mindname = "animal",
    symbol = "d",
}
