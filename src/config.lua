config = {}
config.status = true
config.err = {}
config.status, config.err = pcall(function() require("cuberc") end)
