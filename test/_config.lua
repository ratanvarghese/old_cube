require("_common")
results = {}
if CUBE_CONFIG then
    --Don't want to overwrite existing cuberc
    tmp_name = "./cnf_tmp"
    cmd_1 = "mv " .. CUBE_CONFIG .. " " .. tmp_name
    os.execute(cmd_1)

    orig_msg = "I can ride my bike with no handlebars"
    esc_msg = "\\\"".. orig_msg .. "\\\""
    cmd_2 = "echo \"config.msg = " .. esc_msg .. "\" > " .. CUBE_CONFIG
    os.execute(cmd_2)

    require("config")

    results["Successful interpret"] = orig_msg == config.msg

    cmd_final = "mv " .. tmp_name .. " " .. CUBE_CONFIG
    os.execute(cmd_final)
end

print_results(results, "config")
