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

