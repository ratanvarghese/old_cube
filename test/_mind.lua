require("_common")
require("mind")

results = {}

t = {}
results["Empty table invalid"] = not mind.is_valid(t)

t.co = coroutine.create(function() end)
coroutine.resume(t.co)
t.free_will = 1
results["Spent coroutine invalid"] = not mind.is_valid(t)

t.co = coroutine.create(function() while true do coroutine.yield() end end)
t.free_will = -1
results["Negative free will invalid"] = not mind.is_valid(t)

t.free_will = 1.1
results["Fractional free will invalid"] = not mind.is_valid(t)

t.free_will = 1
results["Detect valid"] = mind.is_valid(t)
