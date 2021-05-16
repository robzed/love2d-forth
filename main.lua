-- Love2D 'middleware' to use Love2D with Forth language.
-- Copyright 2021 Rob Probin, released under MIT license, see file LICENSE
--

require("forthcore")
require("love2dwords")

function love.load()
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    
    main_forth_file, err = love.filesystem.read("main.fth")
    if main_forth_file then
        interpret(main_forth_file)
    end
    interpret("love.load")
    forth_update_xt = get_word_xt("love.update")
    forth_draw_xt = get_word_xt("love.draw")
end

function love.update(dt)
    push(dt)
    execute_xt(forth_update_xt)
end

function love.draw()
    execute_xt(forth_draw_xt)
end

function love.textedited( text, start, length )
    local xt = get_word_xt("love.textedited")
    if xt then
        push(text)
        push(start)
        push(length)
        xt()
    end    
end

function love.textinput( text )
    local xt = get_word_xt("love.textinput")
    if xt then
        push(text)
        xt()
    end    
end
