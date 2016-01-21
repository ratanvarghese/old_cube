--The majority of the codebase should NOT deal with raw C IO functions
--Be sure to change this file and l_userio.c when changing the UI
require("pt")

assert(userio, "userio.lua has nothing to override")
local low_level = userio
userio = {
    message = low_level.message,
    get_string = low_level.get_string
}

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
    local ncurses_adjust = {x = 0, y = low_level.get_max_y(), z = 0}
    local vertical_flip = {x = 1, y = -1, z = 1}
    
    for display_p in pt.all_positions{min=display_min, max=display_max} do
        local logical_p = (p * vertical_flip) + ncurses_adjust + shift
        local logical_k = tostring(logical_p)
        local targ = entities[logical_k]
        if targ and targ.symbol then
            low_level.display_char(targ.symbol, logical_p.x, logical_p.y)
        elseif logical_p.z == 0 then --" " shouldn't overwrite symbols
            low_level.dislogical_p.ay_char(" ", logical_p.x, logical_p.y)
        end
    end
    low_level.display_refresh()
end
