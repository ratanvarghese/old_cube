function print_results(tests, module_name)
    assert(debug, "Attempt to run without test flag")
    local count = 0
    for k,v in pairs(tests) do
        if not v then
            if count == 0 then
                print("Failure(s) in " .. module_name .. ":")
                printed_title = true
            end
            print(k)
            count = count + 1
        end
    end
    if count > 0 then
        print("Total failure(s): " .. count)
        print("")
    end
end
