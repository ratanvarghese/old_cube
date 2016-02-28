require("base")

config = {}

local hook_list = {}
local errhook_list = {}
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

function config.add_errhook(errhook)
    assert(type(errhook) == "function", "Non-function config errhook")
    table.insert(errhook_list, errhook)
end

function config.add_to_userenv(k, v)
    userenv[k] = v
end

if debug then
    function config.reset_module()
        --For debugging ONLY
        --Only resets this module, does not undo hook actions
        hook_list = {}
        userenv = {}
        setmetatable(userenv, userenv_mt)
    end
end

function config.readfile()
    local function readfile_nocatch()
        if CUBE_CONFIG then
            local chunk, err = loadfile(CUBE_CONFIG, "t", userenv)
            if chunk then
                chunk()
            else
                error(err)
            end

            if t.chunk and t.status then
                for i,v in ipairs(hook_list) do
                    v(userinput)
                end
            end
        end
    end

    local status, err = pcall(readfile_nocatch)
    if not status then
        for i,v in pairs(errhook_list) do
            v(userinput)
        end
        return err .. " (in config file)"
    end
end
