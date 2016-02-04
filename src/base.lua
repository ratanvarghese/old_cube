base = {}

function base.copy(src, targ, iter, deep)
    local iter = iter or pairs
    for k,v in iter(src) do
        if type(v) == "table" and deep then
            targ[k] = {}
            base.copy(v, targ[k], iter, deep)
        else
            targ[k] = v
        end
    end
end

function base.remove_v(t, targ_v)
    local targ_k = {}
    for k,v in pairs(t) do
        if v == targ_v then
            targ_k[k] = true
        end
    end
    
    count = 0
    for k in pairs(targ_k) do
        t[k] = nil
        count = count + 1
    end
    return count
end

--[[
CONTRARY TABLES

The key-value pairs of one are the value-key pairs of the other.
They both update at once, one with the opposite key-value to the other.
The metatables of contrary metatables cannot be accessed or changed.
Contrary tables cannot be iterated over using pairs, but pairs-equivalent
iterators are returned as the last two arguments.
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
            fmt.storage[k] = v
            rmt.storage[v] = k
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
