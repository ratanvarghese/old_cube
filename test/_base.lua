require("_common")
require("base")

results = {}
--COPY
overwrite = "meaning"
src = {
    just_called = "to say that it's good to be alive",
    inner_rocks = {"Mercury", "Venus", "Earth", "Mars"},
    [overwrite] = 20,
    "I can ride my bike",
    "With no handlebars"
}
safe_k = "safe"
safe_v = "dont overwrite"
overwrite_v = "please overwrite"
targ1 = {[safe_k] = safe_v, [overwrite] = overwrite_v}
base.copy(src, targ1)
results["copy: shallow permitting"] = true
for k,v in pairs(src) do
    if targ1[k] ~= v then
        results["copy: shallow permitting"] = false
        break
    end
end
results["copy: shallow limiting"] = true
for k,v in pairs(targ1) do
    if src[k] and src[k] ~= v then
        results["copy: shallow limiting"] = false
        break
    end
end
results["copy: no overwrite"] = targ1[safe_k] == safe_v

targ2 = {}
base.copy(src, targ2, pairs, true)
results["copy: deep, no table refs"] = true
results["copy: deep, nested values"] = false
results["copy: deep, normal values"] = true
for k,v in pairs(src) do
    cur_targ = targ2[k]
    if type(cur_targ) == "table" then
        if cur_targ == v then
            results["copy: deep, no table refs"] = false
        else
            results["copy: deep, nested values"] = true
            for vk,vv in pairs(v) do
                if cur_targ[vk] ~= vv then
                    results["copy: deep, nested values"] = false
                end
            end
        end
    elseif cur_targ ~= v then
        results["copy: deep, normal values"] = false
    end
end

targ3 = {}
base.copy(src, targ3, ipairs)
results["copy: actually uses custom iterator"] = true
for k,v in pairs(src) do
    cur_targ = targ3[k]
    if type(k) == "number" and cur_targ ~= v then
        results["copy: actually uses custom iterator"] = false
    elseif type(k) ~= "number" and cur_targ == v then
        results["copy: actually uses custom iterator"] = false
    end
end

targ4 = base.copy(src)
results["copy: return targ"] = true
for k,v in pairs(src) do
    if v ~= targ1[k] then
        results["copy: return targ"] = false
    end
end
for k,v in pairs(src) do
    if v ~= targ4[k] then
        results["copy: return targ"] = false
    end
end
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
yanv = "Yet another new value"
nk1 = "new key 1"
nk2 = "new key 2"
ft[nk1] = yanv
ft[nk2] = yanv
expected_k[nk2] = yanv
results["contrary: one-to-one forward"] = ft[nk1] == nil
results["contrary: one-to-one reverse"] = rt[yanv] == nk2
nk3 = "new key 3"
dv = "decoy value"
rt[dv] = nk3
rt[yanv] = nk3
expected_k[nk2] = nil
expected_k[nk3] = yanv
results["contrary: one-to-one forward (opposite)"] = ft[nk2] == nil
results["contrary: one-to-one reverse (opposite)"] = rt[dv] == nil

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
