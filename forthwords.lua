-- Love2D 'middleware' to use Love2D with Forth language.
-- Copyright 2021 Rob Probin, released under MIT license, see file LICENSE
--
-- NOTES on operation and Word-set - see file README.md


-- n variable name  ( n <name> -- )
add_new_word("variable", function() 
        local name = get_next_word()
        local addr = here()
        allot(1)
        if name then
            compiled_word_list[name] = function() push(addr) end
        else
            error("No name for function")
        end
    end)

local unique_do_index = 1

add_new_word('do', function()
        compile_raw(string.format("local initial%i = pop() local limit%i=(pop()-1) for i%i = initial%i, limit%i do", unique_do_index, unique_do_index, unique_do_index, unique_do_index, unique_do_index))
    end, true)

add_new_word('i', function()
        compile_raw(string.format('push(i%i)', unique_do_index))
    end, true);

add_new_word('loop', function()
        compile_raw('end')
        unique_do_index = unique_do_index + 1
    end, true)

add_new_word('sinterpret', function()
        local old_buffer = input_buffer
        local old_index = input_buffer_index
        local state, err = interpret(pop())
        if not state then
            push(err)
        end
        push(convert_to_forth_bool(state))
        input_buffer = old_buffer
        input_buffer_index = old_index
    end)

add_new_word("count", function()
        push(tos().len)
    end)

add_new_word("dstack@", function()
        local offset = pop()
        local index = dstack_ptr-offset
        push(dstack[index])
    end)

