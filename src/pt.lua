pt = {}
pt.mt = {}

pt.heights = {
    submerged=0,
    terrain=1,
    lying=2,
    sitting=3,
    standing=4,
    pole_vaulting=5,
    flying=6,
}

function pt.at(t)
    local p = {}
    p.x = t.x or 0
    p.y = t.y or 0
    p.z = t.z or 0
    setmetatable(p, pt.mt)
    return p
end

pt.max = pt.at{x = 240 - 1, y = 60 - 1, z = pt.heights.flying}
pt.min = pt.at{x = 0, y = 0, z = 0}

function pt.is_pt(t)
    return getmetatable(t) == pt.mt
end

function pt.valid_position(p)
    if not pt.is_pt(p) then
        return false
    end

    for k in pairs{x=true, y=true, z=true} do
        assert(type(p[k]) == "number", "non-number dimension")
        if p[k] < pt.min[k] or p[k] > pt.max[k] then
            return false
        end
    end
    
    return true
end    

local function vector_add(a, b)
    assert(pt.is_pt(a), "non-pt first arg to vector_add")
    assert(pt.is_pt(b), "non-pt second arg to vector_add")
    local p = pt.at{}
    p.x = a.x + b.x
    p.y = a.y + b.y
    p.z = a.z + b.z
    return p
end
pt.mt.__add = vector_add

local function vector_sub(a, b)
    assert(pt.is_pt(a), "non-pt first arg to vector_sub")
    assert(pt.is_pt(b), "non-pt second arg to vector_sub")
    local p = pt.at{}
    p.x = a.x - b.x
    p.y = a.y - b.y
    p.z = a.z - b.z
    return p
end
pt.mt.__sub = vector_sub

local function vector_mul_everydimension(a, b)
    assert(pt.is_pt(a), "non-pt first arg to vector_mul_everydimension")
    assert(pt.is_pt(b), "non-pt second arg to vector_mul_everydimension")
    local p = pt.at{}
    p.x = a.x * b.x
    p.y = a.y * b.y
    p.z = a.z * b.z
    return p
end
pt.mt.__mul = vector_mul_everydimension

local function vector_div_everydimension(a, b)
    assert(pt.is_pt(a), "non-pt first arg to vector_div_everydimension")
    assert(pt.is_pt(b), "non-pt second arg to vector_div_everydimension")
    local p = pt.at{}
    p.x = a.x / b.x
    p.y = a.y / b.y
    p.z = a.z / b.z
    return p
end
pt.mt.__div = vector_div_everydimension

local function vector_eq(a, b)
    assert(pt.is_pt(a), "non-pt first arg to vector_eq")
    assert(pt.is_pt(b), "non-pt second arg to vector_eq")
    if a.x == b.x and a.y == b.y and a.z == b.z then
        return true
    else
        return false
    end
end
pt.mt.__eq = vector_eq

local function vector_to_string(p)
    assert(pt.is_pt(p), "non_pt arg to vector_to_string")
    local format = "{[\"x\"]=%d, [\"y\"]=%d, [\"z\"]=%d}"
    return string.format(format, p.x, p.y, p.z)
end
pt.mt.__tostring = vector_to_string

local function iter(range, p)
    if not p then
        return nil
    elseif p.x < range.max.x then
        return pt.at{x=p.x+1, y=p.y, z=p.z}
    elseif p.y < range.max.y then
        return pt.at{x=range.min.x, y=p.y+1, z=p.z}
    elseif p.z < range.max.z then
        return pt.at{x=range.min.x, y=range.min.y, z=p.z+1}
    else
        return nil
    end
end

function pt.all_positions(range)
    if type(range) ~= "table" then
        range = {}
    end
    if not pt.valid_position(range.min) then
        range.min = pt.min
    end
    if not pt.valid_position(range.max) then
        range.max = pt.max
    end
    
    assert(range.max.x >= range.min.x, "invalid range.*.x")
    assert(range.max.y >= range.min.y, "invalid range.*.y")
    assert(range.max.z >= range.min.z, "invalid range.*.z")

    local initial = pt.at{x=range.min.x-1, y=range.min.y, z=range.min.z}
    return iter, range, initial
end

pt.north = pt.at{y=-1}
pt.south = pt.at{y=1}
pt.west = pt.at{x=-1}
pt.east = pt.at{x=1}
pt.northwest = pt.north + pt.west
pt.northeast = pt.north + pt.east
pt.southwest = pt.south + pt.west
pt.southeast = pt.south + pt.east
