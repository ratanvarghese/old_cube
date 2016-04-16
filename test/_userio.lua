--Only tests the Lua portion of userio
require("_common")
require("_mockio")

local results = {}
local mock_io, real_io = mockio.new()
userio = mock_io

require("userio")
require("pt")
require("stage")

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
center = pt.at{x=10, y=10, z=pt.heights.stand}
army_start = center - pt.at{x=phalanx_side, y=phalanx_side, z=0}
floor_start = pt.at{x=pt.min.x, y=pt.min.y, z=pt.heights.terrain}
floor_end = pt.at{x=pt.max.x, y=pt.max.y, z=pt.heights.terrain}

herd_start = pt.at{x=60, y=40, z=pt.heights.stand}
herd_end = pt.at{x=70, y=50, z=pt.heights.stand}

my_stage = stage.new()
for p in pt.all_positions{min=floor_start, max=floor_end} do
    my_stage[p] = floor
end

for p in pt.all_positions{min=herd_start, max=herd_end} do
    my_stage[p] = sheeple
end

for p in pt.all_positions{min=army_start, max=center} do
    my_stage[p] = dude
end

upper_gap = 2
userio.display(my_stage, center - pt.at{x=0, y=upper_gap, z=0})

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
