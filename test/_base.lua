require("_common")
require("base")

results = {}

ik = "Initial key"
iv = "Initial value"
ft, rt = base.mirrored{[ik]=iv}
results["mirrored: initial forward"] = ft[ik] == iv
results["mirrored: initial reverse"] = rt[iv] == ik
fk = "Forward key"
fv = "Forward value"
ft[fk] = fv
results["mirrored: newindex forward"] = ft[fk] == fv
results["mirrored: newindex reverse"] = rt[fv] == fk
nv = "New value"
ft[fk] = nv
results["mirrored: overwrite forward"] = ft[fk] == nv
results["mirrored: overwrite reverse"] = rt[nv] == fk
rk = "Reverse key"
rv = "Reverse value"
rt[rk] = rv
results["mirrored: newindex forward (opposite)"] = ft[rv] == rk
results["mirrored: newindex reverse (opposite)"] = rt[rk] == rv
anv = "Another new value"
rt[rk] = anv
results["mirrored: overwrite forward (opposite)"] = ft[anv] == rk
results["mirrored: overwrite reverse (opposite)"] = rt[rk] == anv
results["mirrored: full key-value check forward"] = true
for k,v in pairs(ft) do
    if rt[v] ~= k then
        results["mirrored: full key-value check forward"] = false
        break
    end
end
results["mirrored: full key-value check reverse"] = true
for k,v in pairs(rt) do
    if ft[v] ~= k then
        results["mirrored: full key-value check forward"] = false
        break
    end
end

print_results(results, "base")
