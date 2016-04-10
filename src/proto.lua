proto = {}

local all_proto = {}

function proto.register(t)
    assert(type(t.name) == "string", "Non string name for prototype")
    all_proto[t.name] = t

    local supername = t.super
    if supername then
        local super = all_proto[supername]
        assert(super, "Unrecognized supertype " .. tostring(supername))
        setmetatable(t, {__index = super})
        t.super = super --Yes, replacing name with table reference
    end
end

function proto.clone_of(s)
    local res_proto = all_proto[s]
    assert(res_proto, "Unrecognized prototype " .. tostring(s))

    local res = {}
    setmetatable(res, {__index = res_proto})
    local init = res_proto.clone_init
    if init then
        init(res, res_proto)
    end
    return res
end
