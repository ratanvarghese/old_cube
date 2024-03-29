base = {}

function base.join_list(src, dest)
    return table.move(src, 1, #src, #dest + 1, dest)
end

function base.copy(src, targ, iter, deep)
    local targ = targ or {}
    local iter = iter or pairs
    for k,v in iter(src) do
        if type(v) == "table" and deep then
            targ[k] = {}
            base.copy(v, targ[k], iter, deep)
        else
            targ[k] = v
        end
    end
    return targ
end

function base.remove_v(t, targ_v)
    local count = 0
    for k,v in pairs(t) do
        if v == targ_v then
            t[k] = nil
            count = count + 1
        end
    end
    return count
end

--[[
CONTRARY TABLES

The key-value pairs of one are the value-key pairs of the other.
They both update at once, one with the opposite key-value to the other.
Both the forward and the reverse tables have one-to-one key-value
relationships: if a new key is added for an existing value, the old key
is removed.
The metatables of contrary tables cannot be accessed or changed.
Contrary tables cannot be iterated over using pairs, but pairs-equivalent
iterators are returned as the last two return values.
Iterable key-values in init will be transferred to the forward table,
and transferred to the reverse table as value-keys.
--]]

function base.contrary(init)
    local function contrary_mt(fmt, rmt)
        fmt.__index = fmt.storage
        fmt.__newindex = function(t, k, v)
            if fmt.storage[k] then
                --removing old values in reverse table
                base.remove_v(rmt.storage, k)
            end
            if rmt.storage[v] then
                --removing old keys in this table!
                base.remove_v(fmt.storage, v)
            end
            if k ~= nil then fmt.storage[k] = v end
            if v ~= nil then rmt.storage[v] = k end
        end
        fmt.__metatable = false
    end

    local function contrary_pairs(mt)
        return function()
            return next, mt.storage, nil
        end
    end

    local forward = {}
    local reverse = {}

    local fmt = {storage = {}}
    local rmt = {storage = {}}
    contrary_mt(fmt, rmt)
    contrary_mt(rmt, fmt)
    setmetatable(forward, fmt)
    setmetatable(reverse, rmt)

    if init then
        for k,v in pairs(init) do
            forward[k] = v
        end
    end

    return forward, reverse, contrary_pairs(fmt), contrary_pairs(rmt)
end
