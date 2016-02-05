--The majority of the codebase should NOT deal with raw C IO functions
--Be sure to change this file and l_userio.c when changing the UI
--In the current UI, this file handles control schemes and IO
require("pt")
require("config")
require("base")

assert(userio, "userio.lua has nothing to override")
local low_level = userio
userio = {
    message = low_level.message,
    get_string = low_level.get_string,
}

-- CONTROL SCHEMES
local default_controls = {}
default_controls.yes_no = {y=true, n=false}
default_controls.yes_no_paranoid = {yes=true, no=false}
default_controls.direction = {
    k = pt.north,
    j = pt.south,
    h = pt.west,
    l = pt.east,
    y = pt.northwest,
    u = pt.northeast,
    b = pt.southwest,
    n = pt.southeast
}
default_controls.main = {
    q = "quit",
    ["?"] = "help"
}
base.copy(default_controls.direction, default_controls.main)

function userio.set_default_controls()
    userio.controls = {}
    userio.rev_controls = {}
    userio.controls_pairs = {}
    userio.controls_rpairs = {}
    for k,v in pairs(default_controls) do
        f, r, fpairs, rpairs = base.contrary(v)
        userio.controls[k] = f
        userio.rev_controls[k] = r
        userio.controls_pairs[k] = fpairs
        userio.controls_rpairs[k] = rpairs
    end
    userio.controls_ready = true
end

function userio.set_controls(t)
    local config_controls = t.controls
    if not userio.controls_ready then
        userio.set_default_controls()
    end
    
    if not config_controls then
        userio.message("No custom controls...")
        return nil
    end

    local results = {success = true}
    for k,v in pairs(config_controls) do
        if userio.controls[k] == nil then
            results.err = "Invalid control context: " .. k
            results.success = false
            break
        end
        for vk,vv in pairs(v) do
            if userio.controls[k][vk] ~= nil then
                -- ["k"] = [...].pt.north
                userio.controls[k][vk] = vv
            elseif userio.rev_controls[k][vv] ~= nil then
                -- as above, but for totally new keys
                userio.rev_controls[k][vv] = vk
            elseif userio.rev_controls[k][vk] ~= nil then
                -- [[...].pt.north] = "k"
                userio.rev_controls[k][vk] = vv
            elseif userio.controls[k][vv] ~= nil then
                -- as above, but for totally new keys
                userio.controls[k][vv] = vk
            else
                vks = tostring(vk)
                vvs = tostring(vv)
                results.err = "Invalid control pair: "
                results.err = results.err .. k .. " " .. vks .. " " .. vvs
                results.success = false
                break
            end
        end
        if not results.success then
            break
        end
    end
    if results.success then
        local main = userio.controls.main
        local direction = userio.controls.direction
        local iter = userio.controls_pairs.direction
        base.copy(direction, main, iter)
    else
        userio.message(results.err .. " (in control config table)")
    end
end

local t = {}
for k in pairs(default_controls) do
    t[k] = {}
end
config.add_to_userenv("controls", t)
config.add_to_userenv("pt", pt.direction)
config.add_hook(userio.set_controls)

-- IO
function userio.input(context, just_one_char, prompt)
    local s = ""
    if just_one_char then
        s = low_level.get_char()
    else
        s = low_level.get_string(prompt)
    end

    return context[s]
end

function userio.display(entities, logical_center)
    local display_min = pt.at{x=0, y=0, z=0}
    local display_max = pt.at{
        x = low_level.get_max_x() - 1,
        y = low_level.get_max_y() - 1,
        z = pt.max.z
    }
    local display_center = pt.at{
        x = low_level.get_max_x()/2 - 1,
        y = low_level.get_max_y()/2 - 1,
        z = logical_center.z
    }
    local shift = logical_center - display_center
    
    for p in pt.all_positions{min=display_min, max=display_max} do
        local logical_p = p + shift
        local logical_k = tostring(logical_p)
        local targ = entities[logical_k]
        if targ and targ.symbol then
            low_level.display_char(targ.symbol, p.x, p.y)
        elseif logical_p.z == 0 then --" " shouldn't overwrite symbols
            low_level.display_char(" ", p.x, p.y)
        end end
    low_level.display_refresh()
end
