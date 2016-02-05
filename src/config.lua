config = {}

local hook_list = {}
local userenv = {}
local userinput = {}
local userenv_mt = {
    __index = userinput,
    __newindex = function(t, k, v)
        userinput[k] = v
    end
}
setmetatable(userenv, userenv_mt)

function config.add_hook(hook)
    assert(type(hook) == "function", "Non-function config hook")
    table.insert(hook_list, hook)
end

function config.add_to_userenv(k, v)
    userenv[k] = v
end

function config.readfile()
    if CUBE_CONFIG then
        local chunk, err = loadfile(CUBE_CONFIG, "t", userenv)
        if chunk then
            chunk()
        else
            error(err)
        end

        for i,v in ipairs(hook_list) do
            v(userinput)
        end
    end
end
