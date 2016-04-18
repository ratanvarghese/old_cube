--[[
POINTS

Points can represent positions in space OR vectors.
Points are compared and arithmetized on by treating each dimension (x,y,z)
individually (dimension comparisons are combined via AND).
--]]

pt = {}
local pt_mt = {}

pt.heights={submerge=0,terrain=1,lie=2,sit=3,stand=4,polevault=5,fly=6}

function pt.at(t)
    local p = {x = t.x or 0, y = t.y or 0, z = t.z or 0}
    setmetatable(p, pt_mt)
    return p
end

pt.max = pt.at{x = 240 - 1, y = 60 - 1, z = pt.heights.fly}
pt.min = pt.at{x = 0, y = 0, z = pt.heights.submerge}

function pt.is_pt(t)
    return getmetatable(t) == pt_mt
end

function pt.valid_position(p)
    return pt.is_pt(p) and p >= pt.min and p <= pt.max
end    

function pt.is_edge(p)
    if p.x == pt.min.x or p.y == pt.min.y then
        return true
    elseif p.x == pt.max.x or p.y == pt.max.y then
        return true
    else
        return false
    end
end

function pt_mt.__add(a,b) return pt.at{x=a.x+b.x,y=a.y+b.y,z=a.z+b.z} end
function pt_mt.__sub(a,b) return pt.at{x=a.x-b.x,y=a.y-b.y,z=a.z-b.z} end
function pt_mt.__mul(a,b) return pt.at{x=a.x*b.x,y=a.y*b.y,z=a.z*b.z} end
function pt_mt.__div(a,b) return pt.at{x=a.x/b.x,y=a.y/b.y,z=a.z/b.z} end
function pt_mt.__eq(a,b) return a.x==b.x and a.y==b.y and a.z==b.z end
function pt_mt.__lt(a,b) return a.x<b.x and a.y<b.y and a.z<b.z end
function pt_mt.__le(a,b) return a.x<=b.x and a.y<=b.y and a.z<=b.z end

function pt_mt.__tostring(p)
    local format = "{[\"x\"]=%d, [\"y\"]=%d, [\"z\"]=%d}"
    return string.format(format, p.x, p.y, p.z)
end

function pt.hash(p)
    --Only needed for valid positions, not vectors.
    --x coordinate fits in 8 bit int, y in 6 bit, z in 4 bit
    return ( p.z ) | ( p.y << 4 ) | ( p.x << 10 )
end

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
    local range = range or {}
    range.min = range.min or pt.min
    range.max = range.max or pt.max
    
    assert(range.max >= range.min, "range max exceeds min")

    local initial = pt.at{x=range.min.x-1, y=range.min.y, z=range.min.z}
    return iter, range, initial
end

pt.direction = {
    north = pt.at{y=-1},
    south = pt.at{y=1},
    west = pt.at{x=-1},
    east = pt.at{x=1},
    up = pt.at{z=1},
    down = pt.at{z=-1}
}
pt.direction.northwest = pt.direction.north + pt.direction.west
pt.direction.northeast = pt.direction.north + pt.direction.east
pt.direction.southwest = pt.direction.south + pt.direction.west
pt.direction.southeast = pt.direction.south + pt.direction.east
