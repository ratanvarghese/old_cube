--The majority of the codebase should NOT deal with raw C IO functions
--Be sure to change this file and l_userio.c when changing the UI
require("base")
require("pt")
require("control")
require("replay")

assert(userio, "userio.lua has nothing to override")
local low_level = userio
userio = {}

-- CONTROL SCHEMES
control.new_default{
    yes_no = {
        yes = "y",
        no = "n"
    },
    yes_no_paranoid = {
        yes = "yes",
        no = "no"
    },
    direction = {
        north = "k",
        south = "j",
        west = "h",
        east = "l",
        northwest = "y",
        northeast = "u",
        southwest = "b",
        southeast = "n",
        up = "<",
        down = ">"
    },
    player = {
        quit = "q",
        help = "?"
    }
}

-- IO
function userio.message(m)
    if not REPLAY_MODE then
        low_level.message(m)
    end
end

function userio.get_string(prompt, override)
    local s, justchanged = replay.old_act()
    if s then
        if justchanged then
            userio.display(nil, nil, true)
        end
        return s
    else
        return low_level.get_string(prompt)
    end
end

function userio.input(context, just_one_char, prompt)
    local s, justchanged = replay.old_act()
    if s then
        if justchanged then
            userio.display(nil, nil, true)
        end
        return s
    end

    if just_one_char then --Use low_level to avoid pulling old_acts
        s = low_level.get_char()
    else
        s = low_level.get_string(prompt)
    end

    if type(context) == "string" then
        assert(control.rev[context], "Invalid control context" .. context)
        return control.rev[context][s]
    elseif type(context) == "table" then
        for i,v in ipairs(context) do
            assert(control.rev[v], "Invalid control context" .. v)
            local targ_ctrl = control.rev[v][s]
            if targ_ctrl then
                replay.record_act(targ_ctrl)
                return targ_ctrl
            end
        end
    end
    return false
end

local prev_logic_center = pt.min
local prev_entities = {}
function userio.display(entities, logical_center, override)
    if logical_center then
        prev_logic_center = logical_center
    else
        logical_center = prev_logic_center
    end

    if entities then
        prev_entities = entities
    else
        entities = prev_entities
    end

    local cond_r = (REPLAY_MODE and REPLAY_MODE ~= replay.modes.visual)
    if not override and cond_r then
        return
    end

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
        local targ = entities[logical_p]
        if targ and targ.symbol then
            low_level.display_char(targ.symbol, p.x, p.y)
        elseif logical_p.z == 0 then --" " shouldn't overwrite symbols
            low_level.display_char(" ", p.x, p.y)
        end
    end
    low_level.display_refresh()
end
