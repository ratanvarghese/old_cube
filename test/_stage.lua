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

ent = {}
old_pt = pt.at{x=2, y=4}
new_pt = pt.at{x=8, y=16}
stage.add_ent(my_stage, ent, old_pt)
stage.mv_ent(ent.stage, ent, new_pt)
results["mv occupy new_pt"] = my_stage[new_pt] == ent
results["mv free old_pt"] = my_stage[old_pt] == nil

newest_pt = pt.at{x=16, y=4}
stage.mv_ent(ent.stage, ent, newest_pt)
results["mv update ent"] = ent.pt == newest_pt

print_results(results, "stage")
