require("_common")
require("pt")
--pt is supposed to represent both vectors and positions

results = {}

local expected_1 = {x=1, y=2, z=3}
local pt_1 = pt.at(expected_1)
results["Expected values on creation"] = true
results["Expected value types on creation"] = true
for k,v in pairs(expected_1) do
    if pt_1[k] ~= v then
        results["Expected values on creation"] = false
    end
    if math.type(pt_1[k]) ~= "integer" then
        results["Expected value types on creation"] = false
    end
end

local expected_2 = string.format("{[\"x\"]=%d, [\"y\"]=%d, [\"z\"]=%d}",
                                expected_1.x, expected_1.y, expected_1.z)
results["String conversion"] = tostring(pt_1) == expected_2

local pt_2 = pt.at(expected_1)
results["Non-copied equality respected"] = pt_2 == pt_1

pt_2.x = pt_1.x + 10
results["Inequality"] = pt_2 ~= pt_1

local pt_3 = pt.at(pt_1)
results["Copied values equal"] = pt_3 == pt_1

pt_3.x = pt_1.x + 10
results["Copied values change independently"] = pt_3.x ~= pt_1.x

local expected_3 = {
    x = pt_1.x + pt_3.x,
    y = pt_1.y + pt_3.y,
    z = pt_1.z + pt_3.z,
}
local pt_4 = pt_1 + pt_3
results["Addition"] = pt_4 == pt.at(expected_3)

local expected_4 = {
    x = pt_1.x - pt_3.x,
    y = pt_1.y - pt_3.y,
    z = pt_1.z - pt_3.z,
}
local pt_5 = pt_1 - pt_3
results["Subtraction"] = pt_5 == pt.at(expected_4)

local expected_5 = {
    x = pt_1.x * pt_3.x,
    y = pt_1.y * pt_3.y,
    z = pt_1.z * pt_3.z,
}
local pt_6 = pt_1 * pt_3
results["Multiplication"] = pt_6 == pt.at(expected_5)

local expected_6 = {
    x = pt_1.x / pt_3.x,
    y = pt_1.y / pt_3.y,
    z = pt_1.z / pt_3.z,
}
local pt_7 = pt_1 / pt_3
results["Division"] = pt_7 == pt.at(expected_6)

local my_map = {}
results["All intended points are valid"] = true
for ix=0,pt.max.x do
    for iy=0,pt.max.y do
        for iz=0,pt.max.z do
            local p = pt.at{x=ix, y=iy, z=iz}
            if not pt.valid_position(p) then
                tests["All intended points are valid"] = false
                break
            end
            my_map[tostring(p)] = 1
        end
    end
end

results["Invalidity lower bound limiting check"] = true
results["Invalidity lower bound permitting check"] = true
for ix=pt.min.x-1,pt.min.x do
    for iy=pt.min.y-1,pt.min.y do
        for iz=pt.min.z-1,pt.min.z do
            local p = pt.at{x=ix, y=iy, z=iz}
            local cond1 = p.x < pt.min.x
            local cond2 = p.y < pt.min.y
            local cond3 = p.z < pt.min.z
            local orcond = cond1 or cond2 or cond3
            local notcond = not cond1 and not cond2 and not cond3
            if pt.valid_position(p) and orcond then
                results["Invalidity lower bound limiting check"] = false
            elseif not pt.valid_position(p) and notcond then
                results["Invalidity lower bound permitting check"] = false
            end
        end
    end
end

results["Invalidity upper bound limiting check"] = true
results["Invalidity upper bound permitting check"] = true
for ix=pt.max.x,pt.max.x+1 do
    for iy=pt.max.y,pt.max.y+1 do
        for iz=pt.max.z,pt.max.z+1 do
            local p = pt.at{x=ix, y=iy, z=iz}
            local cond1 = p.x > pt.max.x
            local cond2 = p.y > pt.max.y
            local cond3 = p.z > pt.max.z
            local orcond = cond1 or cond2 or cond3
            local notcond = not cond1 and not cond2 and not cond3
            if pt.valid_position(p) and orcond then
                results["Invalidity upper bound limiting check"] = false
            elseif not pt.valid_position(p) and notcond then
                results["Invalidity upper bound permitting check"] = false
            end
        end
    end
end

results["pt.all_positions() covers all positions"] = true

for p in pt.all_positions() do
    my_map[tostring(p)] = 2
end

for k,v in pairs(my_map) do
    if v ~= 2 then
        results["pt.all_positions() covers all positions"] = false
    end
end

results["pt.all_positions() range limiting"] = true
results["pt.all_positions() range permitting"] = true
local my_range = {min=pt.at{x=1, y=1, z=1}, max=pt.at{x=3, y=3, z=3}}

for p in pt.all_positions(my_range) do
    my_map[tostring(p)] = 3
end

for p in pt.all_positions() do
    local cond1 = p.x >= my_range.min.x and p.x <= my_range.max.x
    local cond2 = p.y >= my_range.min.y and p.y <= my_range.max.y
    local cond3 = p.z >= my_range.min.z and p.z <= my_range.max.z

    if cond1 and cond2 and cond3 then
        if my_map[tostring(p)] ~= 3 then
            results["pt.all_positions() range permitting"] = false
        end
    else
        if my_map[tostring(p)] == 3 then
            results["pt.all_positions() range limiting"] = false
        end
    end
end

print_results(results, "pt")
