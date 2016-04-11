require("proto")

proto.register{
    name = "monster",
    clone_init = function() end, --Nothing yet...
}

proto.register{
    name = "human",
    supername = "monster",
    symbol = "@",
}

proto.register{
    name = "dog",
    supername = "monster",
    symbol = "d",
}
