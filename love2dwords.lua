-- Love2D 'middleware' to use Love2D with Forth language.
-- Copyright 2021 Rob Probin, released under MIT license, see file LICENSE
--


-- Can we add these automatically somehow with introspection?
-- Number of parameters might be tricky?
-- at least make a table?

add_new_word('love.graphics.print', function()
        drop() -- drop length
        love.graphics.print(pop(), pop(), pop())
    end)

add_new_word('love.keyboard.setTextInput1', function() love.keyboard.setTextInput(pop()) end)

-- love.keyboard.setTextInput( enable, x, y, w, h )

add_new_word('love.keyboard.hasTextInput', function() push(love.keyboard.hasTextInput) end)

