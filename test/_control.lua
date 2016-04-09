require("_common")
require("control")

results = {}

test1 = "Incomplete default check"
results[test1] = not pcall(function() control.new_default{} end)

test2 = "Incomplete default subgroups check"
results[test2] = not pcall(function() control.new_default{
    yes_no = {}, --This is the incomplete one
    --Yanked from userio.lua, much like below. 
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
} end)

--Yanked from userio.lua, ncurses version
--Will need to re-yank as controls expand.
local default = {
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

test3 = "Setting valid new default"
results[test3] = pcall(function() control.new_default(default) end)

test4 = "All control subgroups exist forward"
test5 = "All control subgroups exist reverse"
test6 = "Initial current controls mirror default, inclusive"
test7 = "Initial reverse controls mirror default, inclusive"
results[test4] = true
results[test5] = true
results[test6] = true
results[test7] = true
for k,v in pairs(default) do
    local curv = control.cur[k]
    if curv then
        for vk, vv in pairs(v) do
            if control.cur[k][vk] ~= vv then
                results[test6] = false
            end
        end
    else
        result[test4] = false
    end

    local revv = control.rev[k]
    if revv then
        for vk, vv in pairs(v) do
            if control.rev[k][vv] ~= vk then
                results[test7] = false
            end
        end
    else
        result[test5] = false
    end
end

control.cur.main = nil
test8 = "Invalid with removed subgroup"
results[test8] = not pcall(function() control.validate_cur() end)

control.reset()
test9 = "Valid after reset"
results[test9] = pcall(function() control.validate_cur() end)

control.cur.extra_unneeded_subgroup = {}
test10 = "Invalid with extra subgroup"
results[test10] = not pcall(function() control.validate_cur() end)

control.reset()
control.cur.main.quit = nil
test11 = "Invalid with single missing control"
results[test11] = not pcall(function() control.validate_cur() end)

print_results(results, "control")
