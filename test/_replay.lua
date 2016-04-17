require("_common")
require("replay")

local tests = {}

local base_name = "test"
local filename = SAVE_DIR .. base_name .. ".qbs"

os.remove(filename)

replay.init(base_name)

tests["Empty past action"] = not replay.old_act()

local record_1 = "myrec"
local record_2 = "myotherec"
local record_count = 1000

for i=1,record_count do
    replay.record_act(record_1)
    replay.record_act(record_2)
end
replay.save()

tests["File access"] = true
local file = io.open(filename, "r")

if not file then
    tests["File access"] = false
    test_results(tests, "replay")
    os.exit()
end

local line_num = 0
tests["Action recording"] = true
for l in file:lines() do
    line_num = line_num + 1
    if line_num == 1 then
        local seedrec = tonumber(l)
        tests["Metaseed recording"] = seedrec == rng.metaseed
    elseif line_num % 2 == 0 and l ~= record_1 then
        tests["Action recording"] = false
    end
end

local predicted_num = 1 + (record_count * 2)
tests["Total recording"] = line_num == predicted_num

file:close()

local old_seed = rng.metaseed
rng.metaseed = 0
replay.init(base_name)
tests["Preserved metaseed"] = rng.metaseed == old_seed

tests["Preserved action"] = true
tests["Preserved length"] = true
tests["Correct on mode interval"] = true
tests["Correct off mode interval"] = true
line_num = 0
local act = true
while act do
    act = replay.old_act()
    line_num = line_num + 1
    if line_num > (predicted_num) then
        tests["Preserved length"] = false
    elseif line_num < (predicted_num) and not REPLAY_MODE then
        tests["Correct on mode interval"] = false
    elseif line_num == (predicted_num) and REPLAY_MODE then
        tests["Correct off mode interval"] = false
    end

    if REPLAY_MODE and act ~= record_1 and act ~= record_2 then
        tests["Preserved action"] = false
    end
end

print_results(tests, "replay")
