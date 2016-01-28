require("_common")
require("base")

results = {}
--REMOVE_V
set_t = {"Just", "called", "to", "say", "that", "it's", "good", "to be"}
set_f = {"I", "can", "ride", "my", "bike", "with", "no", "handlebars" }
target = {}
for k,v in pairs(set_t) do
    target[v] = "keep"
end
for k,v in pairs(set_f) do
    target[v] = "remove"
end
base.remove_v(target, "remove")
results["remove_v: permitting"] = true
for k,v in pairs(set_t) do
    if target[v] ~= "keep" then
        results["remove_v: permitting"] = false
        break
    end
end
results["remove_v: limiting"] = true
for k,v in pairs(set_f) do
    if target[v] then
        results["remove_v: limiting"] = false
    end
end

--CONTRARY
ik = "Initial key"
iv = "Initial value"
ft, rt, fpairs, rpairs = base.contrary{[ik]=iv}
expected_k = {[ik] = iv}
results["contrary: initial forward"] = ft[ik] == iv
results["contrary: initial reverse"] = rt[iv] == ik
fk = "Forward key"
fv = "Forward value"
ft[fk] = fv
expected_k[fk] = fv
results["contrary: newindex forward"] = ft[fk] == fv
results["contrary: newindex reverse"] = rt[fv] == fk
nv = "New value"
ft[fk] = nv
expected_k[fk] = nv
results["contrary: overwrite forward"] = ft[fk] == nv
results["contrary: overwrite reverse"] = rt[nv] == fk
rk = "Reverse key"
rv = "Reverse value"
rt[rk] = rv
expected_k[rv] = rk
results["contrary: newindex forward (opposite)"] = ft[rv] == rk
results["contrary: newindex reverse (opposite)"] = rt[rk] == rv
anv = "Another new value"
rt[rk] = anv
expected_k[rv] = nil
expected_k[anv] = rk
results["contrary: overwrite forward (opposite)"] = ft[anv] == rk
results["contrary: overwrite reverse (opposite)"] = rt[rk] == anv
results["contrary: full key-value check forward"] = true
results["contrary: fpairs keys limiting"] = true
actual_k = {}
for k,v in fpairs() do
    if rt[v] ~= k then
        results["contrary: full key-value check forward"] = false
        print(k, v, rt[v])
    end
    if not expected_k[k] then
        results["contrary: fpairs keys limiting"] = false
    end
    actual_k[k] = v 
end
results["contrary: fpairs keys permitting"] = true
results["contrary: fpairs expected key-values"] = true
for k,v in pairs(expected_k) do
    if not actual_k[k] then
        results["contrary: fpairs keys permitting"] = false
    end
    if actual_k[k] ~= v then
        results["contrary: fpairs expected key-values"] = false
    end
end
results["contrary: full key-value check reverse"] = true
for k,v in rpairs() do
    if ft[v] ~= k then
        results["contrary: full key-value check forward"] = false
        break
    end
end

print_results(results, "base")
