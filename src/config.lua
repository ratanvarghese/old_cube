config = {}
config.chunk, config.err = loadfile(CUBE_CONFIG, "t", {config=config})
if config.chunk then
    config.chunk()
end
