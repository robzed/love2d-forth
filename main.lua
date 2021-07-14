-- Love2D 'middleware' to use Love2D with Forth language.
-- Copyright 2021 Rob Probin, released under MIT license, see file LICENSE
--

require("forthcore")
require("forthwords")
require("lua_interface")
require("love2dwords")

function love.load()
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    
    main_forth_file, err = love.filesystem.read("main.fth")
    if main_forth_file then
        success, err = interpret(main_forth_file)

        if not success then
            print("Problem loading main.fth file")
            print(err)
            success = love.window.showMessageBox("Fatal Error", string.format("Problem loading main.fth file'%s'\n", err) , "error")
            os.exit(1)
        end
        
    end
    interpret("love.load")
end

function love.update(dt)
    push(dt)
    execute_xt(get_word_xt("love.update"))
end

function love.draw()
    execute_xt(get_word_xt("love.draw"))
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

-- Called when text has been entered by the user.
function love.textinput( text )
    local xt = get_word_xt("love.textinput")
    if xt then
        push(text)
        xt()
    end    
end

-- Called when the candidate text for an IME has changed. 	Added since 0.10.0 	
function love.textedited( text, start, length )
    local xt = get_word_xt("love.textedited")
    if xt then
        push(text)
        push(start)
        push(length)
        xt()
    end    
end

-- Callback function triggered when a key is pressed. 		
function love.keypressed( key, scancode, isrepeat )
    local xt = get_word_xt("love.keypressed")
    if xt then
        push(key)
        push(scancode)
        push(isrepeat)
        xt()
    end    
end

-- Callback function triggered when a keyboard key is released. 		
function love.keyreleased( key, scancode )
    local xt = get_word_xt("love.scancode")
    if xt then
        push(key)
        push(scancode)
        xt()
    end    
end


-- need to add more service routines here
