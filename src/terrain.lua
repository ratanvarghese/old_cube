require("proto")

proto.register{
    name = "terrain",
    clone_init = function() end, --Nothing yet
}

proto.register{
    name = "floor",
    supername = "terrain",
    symbol = ".",
}

proto.register{
    name = "wall",
    supername = "terrain",
    symbol = "#",
}
