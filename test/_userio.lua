--Only tests the Lua portion of userio
require("_common")
require("_mockio")

local results = {}
local mock_io, real_io = mockio.new()
userio = mock_io

require("userio")
require("pt")

-- CONTROL SCHEMES
function set1(t)
    userio.set_one_control(t.category, t.cmd, t.key)
end
function set1_r(t)
    userio.set_one_control(t.category, t.key, t.cmd)
end
function setn(t)
    userio.set_custom_controls({[t.kind]={[t.key]=t.cmd}})
end
function setn_r(t) 
    userio.set_custom_controls({[t.kind]={[t.cmd]=t.key}})
end
control_tests = {
    ["set_one_control"] = set1,
    ["set_one_control reverse" ] = set1_r,
    ["set_custom_controls"] = setn,
    ["set_custom_controls reverse"] = setn_r
}

for k,f in pairs(control_tests) do
    local ucontrol = userio.controls
    local ucontrol_r = userio.rev_controls
    local ctrl = {kind="main", cmd="quit", key="e"}
    local oldkey = ucontrol_r[ctrl.kind][ctrl.cmd]
    results["default main keys"] = oldkey ~= nil

    f(ctrl)
    results[k .. " main"] = ucontrol[ctrl.kind][ctrl.key] == ctrl.cmd
    results[k .. " main override"] = ucontrol[ctrl.kind][oldkey] == nil
    
    ctrl = {kind="direction", cmd=pt.north, key="t"}
    oldkey = ucontrol_r.main[ctrl.cmd]
    results["default main copy direction"] = oldkey ~= nil
    f(ctrl)
    local res = ucontrol.main[ctrl.key] == ctrl.cmd
    results[k .. " main copy direction"] = res
    res = ucontrol.main[oldkey] == nil
    results[k .. " main copy direction override"] = res
end

--[[
userio.set_one_control(my_ctrl.category, my_ctrl.ctrl, my_ctrl.key)
r = userio.controls[my_ctrl.category][my_ctrl.key] == my_ctrl.ctrl
results["set_one_control main"] = r
r = userio.controls[my_ctrl.category][oldkey] == nil
results["set_one_control main override"] = r

oldkey = my_ctrl.key
my_ctrl.key = "c"
userio.set_one_control(my_ctrl.category, my_ctrl.key, my_ctrl.ctrl)
r = userio.controls[my_ctrl.category][my_ctrl.key] == my_ctrl.ctrl
results["set_one_control main reverse"] = r
r = userio.controls[my_ctrl.category][oldkey] == nil
results["set_one_control main reverse override"] = r

my_ctrl = {category="direction", ctrl=pt.north, key="t"}
oldkey = userio.rev_controls[my_ctrl.category][my_ctrl.ctrl]
results["set_one_control default direction keys"] = oldkey ~= nil

userio.set_one_control(my_ctrl.category, my_ctrl.ctrl, my_ctrl.key)
r = userio.controls.main[my_ctrl.key] == my_ctrl.ctrl
results["set_one_control copy direction to main"] = r
r = userio.controls.main[oldkey] == nil
results["set_one_control copy direction to main override"] = r

oldkey = my_ctrl.key
my_ctrl.key = "r"
userio.set_one_control(my_ctrl.category, my_ctrl.key, my_ctrl.ctrl)
r = userio.controls.main[my_ctrl.key] == my_ctrl.ctrl
results["set_one_control copy direction to main reverse"] = r
r = userio.controls.main[oldkey] == nil
results["set_one_control copy direction to main reverse override"] = r
--]]

-- IO
msg = "I can ride my bike with no handlebars." --Flobot
userio.message(msg)
results["Message received"] = mock_io.msg_buf[1] == msg

msg = "Blah"
mock_io.unprompted_string_input = msg
msg_final = userio.get_string()
results["Unprompted string input"] = msg == msg_final

expected_prompt = "Why did the chicken cross the road?"
expected_response = "It had no free will."
mock_io.prompted_string_input = {
    [expected_prompt] = expected_response,
    ["What is your name?"] = "I have no free will either",
    ["UMAD?"] = "Probably"
}
final_response = userio.get_string(expected_prompt)
results["Prompted string input"] = final_response == expected_response

dude = {symbol="@"}
floor = {symbol="."}
sheeple = {symbol="q"}
phalanx_side = 5
center = pt.at{x=10, y=10, z=pt.heights.standing}
army_start = center - pt.at{x=phalanx_side, y=phalanx_side, z=0}
floor_start = pt.at{x=pt.min.x, y=pt.min.y, z=pt.heights.terrain}
floor_end = pt.at{x=pt.max.x, y=pt.max.y, z=pt.heights.terrain}

herd_start = pt.at{x=60, y=40, z=pt.heights.standing}
herd_end = pt.at{x=70, y=50, z=pt.heights.standing}

stage = {}
for p in pt.all_positions{min=floor_start, max=floor_end} do
    stage[tostring(p)] = floor
end

for p in pt.all_positions{min=herd_start, max=herd_end} do
    stage[tostring(p)] = sheeple
end

for p in pt.all_positions{min=army_start, max=center} do
    stage[tostring(p)] = dude
end

upper_gap = 2
userio.display(stage, center - pt.at{x=0, y=upper_gap, z=0})

results["Display blank"] = true
results["Display army"] = true
results["Display floor"] = true
d_min = pt.at{x=0, y=0, z=0}
d_max = pt.at{x=mock_io.get_max_x()-1, y=mock_io.get_max_y()-1, z=0}
for p in pt.all_positions{min=d_min, max=d_max} do
    symbol = mock_io.screen[p.x][p.y]
    cond1 = p.x < 29 or p.y < (upper_gap-1)
    cond2 = symbol ~= " "
    if cond1 and cond2 then
        results["Display blank"] = false
    end
    cond1 = p.x > (29+4) and p.y > (upper_gap-1+4)
    cond2 = p.x < (29+11) and p.y < (upper_gap-1+11)
    cond3 = symbol ~= "@"
    if cond1 and cond2 and cond3 then
        results["Display army"] = false
    end
    cond4 = p.x >= 29 and p.y >= upper_gap-1
    cond5 = not cond1 and not cond2
    cond6 = symbol ~= "."
    if cond4 and cond5 and cond6 then
        results["Display floor"] = false
    end
end


print_results(results, "userio (Lua portion)")
