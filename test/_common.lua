function print_results(tests, module_name)
    local printed_title = false
    assert(debug, "Attempt to run without test flag")
    for k,v in pairs(tests) do
        if not v then
            if not printed_title then
                print("Failure(s) in " .. module_name)
                printed_title = true
            end
            print(k)
        end
    end
    if printed_title then
        print("")
    end
end
