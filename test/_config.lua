require("_common")
require("config")

results = {}

if not CUBE_CONFIG then
    results["CUBE_CONFIG exists"] = false
else
    results["CUBE_CONFIG exists"] = true
    local function cache_cuberc(tmp_name)
        --Don't want to overwrite existing cuberc
        os.execute("mv " .. CUBE_CONFIG .. " " .. tmp_name)
    end

    local function restore_cuberc(tmp_name)
        os.execute("mv " .. tmp_name .. " " .. CUBE_CONFIG)
    end

    local function write_cuberc(content)
        local f = assert(io.open(CUBE_CONFIG, "w"))
        f:write(content)
        f:close()
    end
    local tmp_name = "./cnf_tmp"
    cache_cuberc(tmp_name)

    test1 = "Successful interpret"
    results[test1] = false
    msg = "I can ride my bike with no handlebars"
    write_cuberc("msg = \"" .. msg .. "\"")
    config.add_hook(function(t) results[test1] = t.msg == msg end)

    config.readfile()
    restore_cuberc(tmp_name)
end

print_results(results, "config")
