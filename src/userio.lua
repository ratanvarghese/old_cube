--The majority of the codebase should NOT deal with raw C IO functions
--Be sure to change this file and l_userio.c when changing the UI
--In the current UI, this file handles control schemes and IO
require("pt")
require("control")
require("config")
require("base")

assert(userio, "userio.lua has nothing to override")
local low_level = userio
userio = {
    message = low_level.message,
    get_string = low_level.get_string,
}

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
    main = {
        quit = "q",
        help = "?"
    }
}

config.add_to_userenv("control", control.cur)
config.add_hook(function()
    local status, msg = control.validate_cur()
    if not status then
        userio.message(msg .. " in config file")
        control.reset()
    end

end)

-- IO
function userio.input(context, just_one_char, prompt)
    local s = ""
    if just_one_char then
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
            if control.rev[v][s] then
                return control.rev[v][s]
            end
        end
    end
    return false
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
