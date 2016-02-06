require("_common")
require("config")

results = {}

if not CUBE_CONFIG then
    results["CUBE_CONFIG exists"] = false
else
    results["CUBE_CONFIG exists"] = true
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
    local tmp_name = "./cnf_tmp"
    cache_cuberc(tmp_name)

    test1 = "Successful interpret"
    results[test1] = false
    msg = "I can ride my bike with no handlebars"
    f1 = function(t) results[test1] = t.msg == msg end
    config.add_hook(f1)
    write_cuberc("msg = \"" .. msg .. "\"")
    config.readfile()

    config.reset_module()
    test2 = "Add to userenv"
    results[test2] = false
    user_t = {}
    user_tname = "user_tname"
    user_k = "user_k"
    config.add_to_userenv(user_tname, user_t)
    f2 = function(t) results[test2] = t[user_tname][user_k] == msg end 
    config.add_hook(f2)
    write_cuberc(user_tname .. "." .. user_k  .. " = \"" .. msg .. "\"")
    config.readfile()

    config.reset_module()
    restore_cuberc(tmp_name)
end

print_results(results, "config")
