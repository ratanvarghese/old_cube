require("stgen")
rng.init(rng.metaseed)


local s = os.clock()
rng.coin()
local f = os.clock()
print("initial coin flip: " .. f - s .. " seconds")

s = os.clock()
rng.coin()
f = os.clock()
print("second coin flip: " .. f - s .. " seconds")

rep = 1
s = os.clock()
for i=0,rep do
    stgen.g_mono()
end
f = os.clock()
print("stgen.g_mono: " .. f - s .. " seconds")

s = os.clock()
for i=0,rep do
    stgen.g_rand()
end
f = os.clock()
print("stgen.g_rand: " .. f - s .. " seconds")

s = os.clock()
for i=0,rep do
    stgen.g_cell(nil, 1, 3)
end
f = os.clock()
print("stgen.g_cell 1,3: " .. f - s .. " seconds")

s = os.clock()
for i=0,rep do
    stgen.g_cell(nil, 4, 3)
end
f = os.clock()
print("stgen.g_cell 4,3: " .. f - s .. " seconds")
