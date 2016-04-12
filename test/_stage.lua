require("_common")
require("stage")
require("pt")

results = {}

results["is_stage exclusive"] = not stage.is_stage{}

my_stage = stage.new()
results["is_stage inclusive"] = stage.is_stage(my_stage)

test3 = "error on adding invalid key"
results[test3] = not pcall(function() my_stage["invalid key"] = {} end)

test4 = "no error on adding pt key"
results[test4] = pcall(function() my_stage[pt.at{x=1, y=2, z=3}] = {} end)

print_results(results, "stage")
