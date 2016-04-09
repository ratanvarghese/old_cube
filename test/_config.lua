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

    test1 = "Interpret"
    results[test1] = false
    msg = "I can ride my bike with no handlebars"
    f1 = function(t) results[test1] = t.msg == msg end
    config.add_hook(f1)
    test2 = "Error-free ordinary interpret"
    results[test2] = true
    e1 = function(t, e)
        results[test2] = false
        print( e )
    end
    config.add_errhook(e1)
    write_cuberc("msg = \"" .. msg .. "\"")
    config.readfile()

    config.reset_module()
    test3 = "Add to userenv"
    results[test3] = false
    user_t = {}
    user_tname = "user_tname"
    user_k = "user_k"
    config.add_to_userenv(user_tname, user_t)
    f2 = function(t) results[test3] = t[user_tname][user_k] == msg end 
    config.add_hook(f2)
    write_cuberc(user_tname .. "." .. user_k  .. " = \"" .. msg .. "\"")
    config.readfile()

    config.reset_module()
    test4 = "Errhook called"
    test5 = "Errhook includes error message"
    results[test4] = false
    results[test5] = false
    e2 = function(t, e)
        results[test4] = true
        results[test5] = type(e) == "string"
    end
    config.add_errhook(e2)
    write_cuberc("This is not valid lua code, I don't think...")
    config.readfile()

    config.reset_module()
    restore_cuberc(tmp_name)
end

print_results(results, "config")
