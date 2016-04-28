require("pt")
require("base")

geomet = {}

function geomet.bresenham(x1, y1, x2, y2, z)
    local dx = x2 - x1
    local ix = dx > 0 and 1 or -1
    local dx = math.abs(dx)

    local dy = y2 - y1
    local iy = dy > 0 and 1 or -1
    local dy = math.abs(dy)

    local res = {pt.at{x=x1, y=y1, z=z}}
    if dx >= dy then
        local err = dy - (dx / 2)
        while x1 ~= x2 do
            if err >= 0 and (error ~= 0 or ix > 0) then
                err = err - dx
                y1 = y1 + iy
            end

            err = err + dy
            x1 = x1 + ix
            table.insert(res, pt.at{x=x1, y=y1, z=z})
        end
    else
        local err = dx - (dy / 2)
        while y1 ~= y2 do
            if err >= 0 and (error ~= 0 or iy > 0) then
                err = err - dy
                x1 = x1 + ix
            end

            err = err + dx
            y1 = y1 + iy
            table.insert(res, pt.at{x=x1, y=y1, z=z})
        end
    end
    return res
end

function geomet.flood(res, p)
    if res[pt.hash(p)] then
        return
    else
        res[pt.hash(p)] = true
    end

    geomet.flood(res, p + pt.at{x=1})
    geomet.flood(res, p + pt.at{y=1})
    geomet.flood(res, p + pt.at{x=-1})
    geomet.flood(res, p + pt.at{y=-1})
end

function geomet.polygon(vertices, z, res)
    if vertices[#vertices+1] ~= vertices[1] then
        vertices[#vertices+1] = vertices[1]
    end
    local res = res or {}
    local vertex_set = {}
    local bounds = {}
    local start = pt.at{x=pt.max.x, y=pt.max.y, z=z}
    local fin = pt.at{x=pt.min.x, y=pt.min.y, z=z}
    for i,v in ipairs(vertices) do
        vertex_set[pt.hash(v)] = true
        if i > 1 then
            local p1 = vertices[i-1]
            local p2 = v
            local line = geomet.bresenham(p1.x, p1.y, p2.x, p2.y, p2.z)
            for vk,vv in pairs(line) do
                bounds[pt.hash(vv)] = true
            end
        end

        if v.x < start.x then
            start.x = v.x
        end
        if v.x > fin.x then
            fin.x = v.x
        end
        if v.y > fin.y then
            fin.y = v.y
        end
        if v.y < start.y then
            start.y = v.y
        end
    end

    local res = {}
    for hash in pairs(bounds) do
        res[hash] = true
    end

    local cur_val = false
    start = start - pt.at{x=1}
    local prev = start - pt.at{x=1}
    local line_start = nil
    local line_end = nil
    local possible_seed = nil
    for p in pt.all_positions{min=start, max=fin} do
        if p.y ~= prev.y then
            if line_start and line_end and possible_seed then
                geomet.flood(res, possible_seed)
                break
            end
            line_start = nil
            line_end = nil
            possible_seed = nil
        end
        local hashp = pt.hash(p)
        if not line_start and bounds[hashp] then
            line_start = p
        elseif line_start and not line_end then
            if bounds[hashp] then
                line_end = p
            else
                possible_seed = p
            end
        end
        prev = p
    end
    return res, bounds
end
