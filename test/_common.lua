function print_results(tests, module_name)
    print("Testing " .. module_name)
    for k,v in pairs(tests) do
        print(string.format("\t%-44s%+6s", k, tostring(v)))
    end
    print("")
end
