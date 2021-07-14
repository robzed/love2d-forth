-- Interface to Lua primatives
-- Copyright 2021 Rob Probin, released under MIT license, see file LICENSE
-- 
-- Allows flexibility to do Lua things in Forth
--

require('add_word_support')

--[[
# General guidance, in order of priority:
 
 1. This API is intended to provide an interface where no native Forth 
    interface has been provided.
 2. Should look like native Forth where possible, not Lua.
 3. Otherwise should follow native Lua syntax not Lua C API (which is not 
    exposed in Lua anyway).
 4. Lower case Dorth names, to match rest of our Forth - (similar to 
    FlashForth, allowed as an environmental dependacy of the Forth standard)
 5. Make it clear it's lua and avoid conflicts other peoples, e.g L! ... 
    'lua' is a short enough name to be typable. Items 4 and 5 decided 
    between lua of L! lua! Lua! l! (also l! is terrible to read!)
 6. These are not meant to be used directly in an application, but instead 
    used to construct words that provide an interface.
 7. Weak requirement: Avoid underscores where possible. 

--]]

-- lua!   ( n i table -- )
-- stores a value in a lua table table[i] = n
add_new_word('lua!', function()
        local t = pop()
        local i = pop()
        t[i] = pop()
    end)

-- lua{}   ( -- table )
-- makes an empty Lua table
add_new_word("lua{}", function() push({}) end)


-- alternative:
-- lua_execute ( i * x n lua-function -- j * x )
-- i*x are the number of parametres passed
-- n is number of arguments to be to passed to the lua function
-- j*x are the number of parameters returned
 add_new_word('lua_execute', function()
        local f = pop()
        local num_params = pop()
        local params = {}
        while num_params > 0 do
            table.insert(params, pop())
            num_params = num_params - 1
        end
            
        local t = pack(f(unpack(params)))
        for i = 1, t.n do
            push(t[i])
        end
    end)

-- lua_tcall ( table lua-function -- table )
-- all lua parameters must be supplied by a table (internally unpacked)
-- NOTICE: Lua table items for parameters start at 1, as per Lua.
-- return tables has an index n which is the total number of arguments.
-- This is same as Lua 5.2 - 5.4.
--
-- Same as lua_execute, but with table parameters.
--
-- http://lua.2524044.n2.nabble.com/table-pack-td4441858.html
-- uses unpack to do it's job?
 add_new_word('lua_tcall', function()
        local f = pop()
        local t = pack( f(  unpack(pop())  ) )
        push(t)
    end)

-- lua_pcall    ( i *x n lua-function -- j * x f | msg f )
-- f is a flag, true for succeed, false for error
-- In case of any error, pcall returns false plus the error message as a string.
 add_new_word('lua_pcall', function()
        local f = pop()
        local num_params = pop()
        local params = {}
        while num_params > 0 do
            table.insert(params, pop())
            num_params = num_params - 1
        end

        local t = pack(pcall(f, unpack(params)))
        t[1] = convert_to_forth_bool(t[1])
        for i = 1, t.n do
            push(t[i])
        end
     end)

-- lua_xpcall  ( i*x n err-xt lua-function -- j*x f | err f )
-- err-xt ( err -- status )
-- This function is similar to pcall, except that you can set a new Forth
-- error handler. xpcall calls function lua_function in protected mode, 
-- using err-xt as the error handler. Any error inside f is not propagated;
-- instead, xpcall catches the error, calls the err function with the 
-- original error object, and returns a status code. Its first result is 
-- the status code (a boolean), which is true if the call succeeds without 
-- errors. In this case, xpcall also returns all results from the call, 
-- after this first result. In case of any error, xpcall returns false 
-- plus the result from err. 

 add_new_word('lua_xpcall', function()
        local f = pop()
        local err_xt = pop()
        local num_params = pop()
        local params = {}
        while num_params > 0 do
            table.insert(params, pop())
            num_params = num_params - 1

        end
        
        local t = pack(xpcall(f, err_xt, unpack(params)))
        
        t[1] = convert_to_forth_bool(t[1])
        for i = 1, t.n do
            push(t[i])
        end
     end)


-- lua@ ( index table -- value )
--   returns of t[index]
--   index can be a string object, or a numberical index
 add_new_word('lua@', function()
        local t = pop()
        local i = pop()
        push(t[i])
    end)

-- lua_>string ( addr u -- lua-string )
-- Convert a Forth string into a Lua string.
-- NOTE: Since the Forth addresses in this system for strings are
-- actually not addresses but strings, this is the same as 'drop'
add_new_word('lua_>string', compiled_word_list["drop"])

-- lua" ( lua" cccc " -- lua-string ) IMMEDIATE
-- create a lua string. Immediate word, but  can be used from interpret or compile mode.
-- NOTE: Since the Forth addresses in this system for strings are
-- actually not addresses but strings, this is the same as S" cccc" DROP
 add_new_word('lua"', function()
        input_buffer_index = input_buffer_index + 1
        local s = get_delimited_string('"')
        if not s then
            error("Problem with string")
        end
        if state_compile then
            compile_raw(string.format("push(%q) push(%f)", s, s:len()))
        else
            push(s)
            push(len(s))
        end
    end, true)


-- lua_nil  ( -- nil )
-- Lua nil value represented as a Forth stack item
add_new_word('lua_nil', function() push(nil) end)

-- lua_nil?  ( n -- flag )
-- return true (-1) or false (0) depending on whether the stack item is nil
add_new_word('lua_nil?', function() push(convert_to_forth_bool(pop())) end)

-- lua_type ( value -- lua-string )
-- return lua result of type(value)
add_new_word('lua_type', function() push(type(pop())) end)

-- lua@s ( lua-string -- uaddr n )
-- converts a lua string into a forth string
-- Because Forth string addresses are Lua strings, is just a length
add_new_word('lua@s', function() push(#tos()) end)

-- lua#  ( lua-object -- n )
-- returns the length of an object. Useful for strings.
add_new_word('lua#', function() push(#pop()) end)
 
-- lua_VERSION ( -- lua-string )
-- Get the Lua version
add_new_word('lua_VERSION', function() push(_VERSION) end)

-- file = io.open (filename [, mode])
-- io.open ( mode filename | nil filename -- nil file | err nil )
add_new_word("lua_io.open", function() 
        local filename = pop() 
        local f, err = io.open(filename, pop())
        push(err)
        push(f)
    end)

-- io.close ( f -- )
add_new_word("lua_io.close", function() pop():close() end)

-- io.read ( format f -- data )
add_new_word("lua_io.read", function() local f = pop() push(f:read(pop())) end)


-- lua_print ( x -- )
add_new_word("lua_print", function() print(pop()) end)

-- io.write( x -- )
add_new_word("lua_io.write", function()
        io.write(pop())
        end)

add_new_word("lua_io.flush", function() io.flush() end)

--add_new_word("lua_string_char", function() push(string.char(pop())) end)
add_new_word("lua_string_char", function() 
        local tos = pop()
        local s = string.char(tos)
        push(s)
    end)

--
-- things that might be useful
--

add_new_word("lua_loadstring", function() push(loadstring) end)
add_new_word("lua_collectgarbage", function() push(collectgarbage) end)

-- tables for libraries
add_new_word("lua_io", function() push(io) end)
add_new_word("lua_string", function() push(string) end)
add_new_word("lua_math", function() push(math) end)
add_new_word("lua_table", function() push(table) end)
add_new_word("lua_os", function() push(os) end)
add_new_word("lua_coroutine", function() push(coroutine) end)
add_new_word("lua_math", function() push(math) end)
add_new_word("lua_package", function() push(package) end)

    
--[[

#REJECTED INTERFACES

Lua@   -- this should have same syntax as " and C@ ... but for tables rquires two paramters

-- lua[] ( index t -- value ) ... not clear whether it's read or write.

Luacall
LuaNewTable (chosen Lua{})

index can be a string object, or a numberical index

Lnil  ( -- nil )

  Lua nil value represented as a Forth stack item

lua?nil  ( n -- flag )
lua_nul= (n -- flag )

return true (-1) or false (0) depending on whether the stack item is nil

lua_typename  ( value -- s )

Ltype ( value -- s )
  return lua result of type(value)

lua_type ( value -- n )
    return lua result of type(value) as an integer

--]]

