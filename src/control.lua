--userio deals with setting controls in config file
require("base")
require("pt")

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
    main = {
        quit = true,
        help = true
    }
}

local default_control_ready = false
local default_control_table = {}

control = {}
control.cur = {}
control.rev = {}
control.curpairs = {}
control.revpairs = {}
function control.reset()
    for k,v in pairs(default_control_table) do
        local contrary = {base.contrary(v)}
        control.cur[k] = contrary[1]
        control.rev[k] = contrary[2]
        control.curpairs[k] = contrary[3]
        control.revpairs[k] = contrary[4]
    end
end

function control.new_default(t)
    --default control set must be complete!
    local errmsg = "Attempt to change default control table"
    assert(not default_control_ready, errmsg)
        
    for k,v in pairs(valid_control_list) do
        default_control_table[k] = {}
        local errmsg = "new default control table missing subgroup"
        assert(type(t[k]) == "table", errmsg)
        for vk,vv in pairs(v) do
            local errmsg = "new default control table missing control"
            assert(t[k][vk], errmsg)
            default_control_table[k][vk] = t[k][vk]
        end
    end
    default_control_ready = true
    control.reset()
end

function control.validate_cur()
    for k,v in pairs(default_control_table) do
        if not control.cur[k] then
            return false, "missing control subgroup " .. k
        end
        for vk,vv in pairs(v) do
            if not control.cur[k][vk] then
                return false, "missing control ["..k.."]["..vk.."]"
            elseif not type(control.cur[k][vk]) == "string" then
                local msg1 = "wrong type ("..type(control.cur[k][vk])..")"
                local msg2 = "for control ["..k.."]["..vk.."]"
                return false, msg1 .. msg2
            end
        end
    end

    for k,v in pairs(control.cur) do
        if not default_control_table[k] then
            return false, "extra control subgroup " .. k
        end
        for vk,vv in pairs(v) do
            if not default_control_table[vk] then
                return false, "extra control ["..k.."]["..vk.."]"
            end
        end
    end
    return true
end
