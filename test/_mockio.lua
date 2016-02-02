--Interface needs to change in lockstep with l_userio.c

local function new()
    local actual_userio = userio
    local mockery = {
        get_max_x=actual_userio.get_max_x,
        get_max_y=actual_userio.get_max_y,
        is_ready=actual_userio.is_ready,
        msg_buf={},
        prompt_buf={},
        screen={},
        char_input="A",
        prompted_string_input={},
        unprompted_string_input = "A",
        clear_count=0,
        refresh_count=0,
    }

    for ix=0,mockery.get_max_x()-1 do
        mockery.screen[ix] = {}
        for iy=0,mockery.get_max_y()-1 do
            mockery.screen[ix][iy] = "A"
        end
    end

    function mockery.message(s)
        table.insert(mockery.msg_buf, s)
    end

    function mockery.get_char()
        return mockery.char_input
    end

    function mockery.get_string(prompt)
        if prompt then
            table.insert(mockery.prompt_buf, prompt)
            return mockery.prompted_string_input[prompt]
        else
            return mockery.unprompted_string_input
        end
    end

    function mockery.display_char(c, x, y)
        mockery.screen[x][y] = c
    end

    function mockery.display_clear()
        mockery.clear_count = mockery.clear_count + 1
    end

    function mockery.display_refresh()
        mockery.refresh_count = mockery.refresh_count + 1
    end

    return mockery, actual_userio
end

mockio = {new=new}
