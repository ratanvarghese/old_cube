require("_common")
require("time")

local spawn_wait = 2
local kill_wait = 5

local runs = {}
runs.basic = 0
runs.spawner = 0
runs.alt = 0
runs.killer = 0

local co = {}

co.basic = coroutine.create(function()
    while true do
        runs.basic = runs.basic + 1
        coroutine.yield(function()
            runs.basic = runs.basic - 1
        end)
    end
end)

local function spawn_func()
    co.alt = coroutine.create(function()
        while true do
            runs.alt = runs.alt + 1
            coroutine.yield(function()
                runs.alt = runs.alt - 1
            end)
        end
    end)
    time.add(co.alt)
end

co.spawner = coroutine.create(function()
    while true do
        runs.spawner = runs.spawner + 1
        if runs.spawner == spawn_wait then
            spawn_func()
        end
        coroutine.yield(function()
            runs.spawner = runs.spawner - 1
            if runs.spawner == (spawn_wait - 1) then
                time.remove(co.alt)
            end
        end)
    end
end)

co.killer = coroutine.create(function()
    while true do
        runs.killer = runs.killer + 1
        if runs.killer == kill_wait then
            time.remove(co.alt)
        end
        coroutine.yield(function()
            runs.killer = runs.killer - 1
            if runs.killer == (kill_wait - 1) then
                spawn_func()
            end
        end)
    end
end)

-------------------------------------------------------------------------

local tests = {}
local wait_1 = 10
local rev_1 = 5

local wait_2 = spawn_wait
local wait_3 = spawn_wait + 1
local wait_4 = kill_wait
local wait_5 = wait_1

local alt_max = kill_wait - spawn_wait - 1 --kill tick = kill request tick

time.add(co.basic)
time.loop(function() return time.current() < wait_1 end)

tests["Basic tick count"] = time.current() == wait_1
tests["Basic forward loop"] = runs.basic == wait_1

time.reverse(rev_1)
tests["Basic partial tick reverse"] = time.current() == rev_1
tests["Basic partial reverse loop"] = runs.basic == rev_1

time.reverse(0)
tests["Basic complete tick reverse"] = time.current() == 0
tests["Basic complete reverse loop"] = runs.basic == 0

time.add(co.spawner)
time.add(co.killer)

time.loop(function() return time.current() < wait_2 end)

tests["Complex spawn run count"] = runs.spawner == wait_2
tests["Complex pre-spawn check"] = runs.alt == 0
time.loop(function() return time.current() < wait_3 end)

tests["Complex post-spawn check"] = runs.alt == 1

time.loop(function() return time.current() < wait_4 end)
tests["Complex pre-kill check"] = runs.alt == alt_max

time.loop(function() return time.current() < wait_5 end)
tests["Complex post-kill check"] = runs.alt == alt_max

print_results(tests, "time")
