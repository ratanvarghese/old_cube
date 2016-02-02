config = {}

function config.readfile()
    local userinput = {}
    config.userinput = userinput
    local userenv_mt = {
        __index = userinput,
        __newindex = function(t, k, v)
            userinput[k] = v
        end
    }
    local userenv = {}
    setmetatable(userenv, userenv_mt)
    
    config.chunk, config.err = loadfile(CUBE_CONFIG, "t", userenv)
    if config.chunk then
        config.chunk()
    else
        error(config.err)
    end
end

config.readfile()
