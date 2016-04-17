require("control")

local enter_present_hooks = {}
local past_actions = {}
local present_actions = {}
local past_idx = 1
local filename = "default.qbs"

replay = {}
replay.modes = {fast="fast", visual="visual"}

function replay.init(base_name)
    filename = SAVE_DIR .. base_name .. ".qbs"
    local file, err, errnum = io.open(filename, "r")
    if file then
        rng.metaseed = tonumber(file:read())
        assert(rng.metaseed, "invalid seed")
        for l in file:lines() do
            table.insert(past_actions, l)
        end
        REPLAY_MODE = replay.modes[REPLAY_MODE] or replay.modes.fast
    elseif errnum == NONEXIST_FILE_ERRNUM then
        file, err = io.open(filename, "w")
        assert(file, err) --Can't handle it anyway...
        file:write(rng.metaseed, "\n")
        REPLAY_MODE = false
    else
        error(err)
    end
    file:close()
    rng.init(rng.metaseed)
end

function replay.add_enter_present_hook(f)
    assert(type(f) == "function", "Non-function enter present hook")
    table.insert(enter_present_hooks, f)
end

function replay.old_act()
    local result = past_actions[past_idx]
    if result and REPLAY_MODE then
        past_idx = past_idx + 1
        return result, past_actions[past_idx] == nil
    else
        past_actions = {}
        REPLAY_MODE = false
        for i,v in ipairs(enter_present_hooks) do v() end
        return nil
    end
end

function replay.record_act(act)
    if not REPLAY_MODE and not control.cur.player[act] then
        table.insert(present_actions, act)
    end
end

function replay.save()
    local file, err = io.open(filename, "a")
    assert(file, err)
    table.insert(present_actions, "")
    file:write(table.concat(present_actions, "\n"))
    file:close()
    present_actions = {}
end
