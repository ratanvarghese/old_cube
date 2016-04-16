mind = {}

function mind.suits_body(b)
    return mind[b.mindname](b)
end

mind.sentient = function() end

function mind.is_valid(t)
    --TODO: loyalty
    local valid_co_status = {normal = true, suspended = true}
    if math.type(t.free_will) ~= "integer" then
        return false
    elseif t.free_will < 0 then
        return false
    elseif type(t.co) ~= "thread" then
        return false
    elseif not valid_co_status[coroutine.status(t.co)] then
        return false
    else
        return true
    end
end
