require("_common")
require("config")

results = {}

function cache_cuberc(tmp_name)
    --Don't want to overwrite existing cuberc
    os.execute("mv " .. CUBE_CONFIG .. " " .. tmp_name)
end

function restore_cuberc(tmp_name)
    os.execute("mv " .. tmp_name .. " " .. CUBE_CONFIG)
end

function write_cuberc(content)
    local f = assert(io.open(CUBE_CONFIG, "w"))
    f:write(content)
    f:close()
end

if CUBE_CONFIG then
    local tmp_name = "./cnf_tmp"
    cache_cuberc(tmp_name)

    orig_msg = "I can ride my bike with no handlebars"
    write_cuberc("msg = \"" .. orig_msg .. "\"")

    config.readfile()
    results["Successful interpret"] = orig_msg == config.userinput.msg

    restore_cuberc(tmp_name)
end

print_results(results, "config")
