--userio deals with setting controls in config file
require("base")
require("pt")
require("config")

local valid_control_list = {
    yes_no = {
        yes = true,
        no = true
    },
    yes_no_paranoid = {
        yes = true,
        no = true
    },
    direction = base.copy(pt.direction),
    player = {
        quit = true,
        help = true
    }
}

local default_ready = false
local default_table = {}

control = {}
control.valid_list = valid_control_list
control.cur = {}
control.rev = {}
control.curpairs = {}
control.revpairs = {}
function control.reset()
    for k,v in pairs(default_table) do
        local contrary = {base.contrary(v)}
        control.cur[k] = contrary[1]
        control.rev[k] = contrary[2]
        control.curpairs[k] = contrary[3]
        control.revpairs[k] = contrary[4]
    end
end

function control.new_default(t)
    --default control set must be complete!
    assert(not default_ready, "Attempt to change default control table")
        
    for k,v in pairs(valid_control_list) do
        default_table[k] = {}
        local sg = t[k]
        assert(type(sg) == "table", "default ctrl table missing subgroup")
        for vk,vv in pairs(v) do
            assert(sg[vk], "new default control table missing control")
            default_table[k][vk] = sg[vk]
        end
    end
    default_ready = true
    control.reset()
end

function control.validate_cur()
    for k,v in pairs(default_table) do
        assert(type(v) == "table", "missing control subgroup " .. k)
        for vk,vv in pairs(v) do
            local c = control.cur[k][vk]
            assert(type(c) == "string", "bad ctrl ["..k.."]["..vk.."]")
        end
    end

    for k,v in pairs(control.cur) do
        local deftk = default_table[k]
        assert(deftk, "extra control subgroup " .. k)
        for vk,vv in pairs(v) do
            assert(deftk[vk], "extra control ["..k.."]["..vk.."]")
        end
    end
end

config.add_to_userenv("control", control.cur)
config.add_hook(control.validate_cur)
config.add_errhook(control.reset)
