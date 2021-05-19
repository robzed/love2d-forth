-- Love2D 'middleware' to use Love2D with Forth language.
-- Copyright 2021 Rob Probin, released under MIT license, see file LICENSE
--
-- NOTES on operation and Word-set - see file README.md


local dict = {}
local dict_ptr = 1

-- maybe make this a table then collapse into string when finished for speed?
-- (to avoid string concatention cost)
local current_word = ""
local current_word_name = nil

local stack = {}
local stack_ptr = 0     -- no top of stack
    
local return_stack = {}
local return_stack_ptr = 0    -- no top of stack
    
local input_buffer_index = 1
local input_buffer = ""

local state_compile = false
local number_base = 10

-- print function can be replaced
local function fprint(s)
    
end
local fprint_x = 0
local fprint_y = 0

function here()
    return dict_ptr
end

function allot(n)
    dict_ptr = dict_ptr + n
end


function push(p)
    stack_ptr = stack_ptr + 1
    stack[stack_ptr] = p
end

function pop()
    local tos = stack[stack_ptr]
    stack_ptr = stack_ptr - 1
    return tos
end

function tos()
    return stack[stack_ptr]
end

function drop()
    stack_ptr = stack_ptr - 1
end


local function rpush(p)
    return_stack_ptr = return_stack_ptr + 1
    return_stack[return_stack_ptr] = p
end

local function rpop()
    local tos = stack[return_stack_ptr]
    return_stack = return_stack_ptr - 1
    return tos
end

function get_next_word()
    -- capture all non-whitespace characters (%S is opposite of %s) after whitespace
    local starti, endi, pattern = input_buffer:find("%s*(%S+)", input_buffer_index)
    if starti == nil then
        return nil
    end
    input_buffer_index = endi + 1
    return pattern
end

function get_delimited_string(delimiter)
    local starti, endi = input_buffer:find(delimiter, input_buffer_index)
    if starti == nil then
        return nil
    end
    local s = input_buffer:sub(input_buffer_index, starti-1)
    input_buffer_index = endi + 1
    return s
end

function compile_raw(s)
    current_word = current_word .. s .. "\n"
end

 compiled_word_list = {
    ["."] = function() print(pop()) end,
    ["dup"] = function() push(stack[stack_ptr]) end,
    -- drop 
    ["drop"] = function() stack_ptr = stack_ptr - 1 end,
    ["["] = function()
        state_compile = false
    end,
    ["]"] = function()
        state_compile = true
    end,
    [":"] = function() 
        local word = get_next_word()
        if word then
            current_word_name = word
            state_compile = true
        else
            error("No name for function")
        end
    end,
    ['S"'] = function()
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
    end
    
    --['(S")'] = function()
    --end
}

local immediate_word_list = {
    ['S"'] = true,
}


-- this isolate downstream word definition from core storage method
function add_new_word(wordname, func, immediate)
   compiled_word_list[wordname] = func
   immediate_word_list[wordname] = immediate
end


-- this one 'compiles' the Lua
function finalise_word()
    local func, err = loadstring(current_word, current_word_name)
    if func == nil then
        error(err)
    end
    compiled_word_list[current_word_name] = func
end

add_new_word(";", function()
    finalise_word()
    state_compile = false
end, true)

-- ( comments )
add_new_word("(", function()
    get_delimited_string(')')
end, true)

-- \ comment to end of line
add_new_word("\\", function()
    local starti, endi = input_buffer:find('\r', input_buffer_index)
    local startj, endj = input_buffer:find('\n', input_buffer_index)
    if starti == nil and startj == nil then
        input_buffer_index = len(input_buffer) + 1
    end
    if starti and startj then
        endi = math.min(endi, endj)
    elseif startj then
        endi = endj
    end
    input_buffer_index = endi + 1
    
end, true)


-- find word in dictionary search order?
function find_word_in_dict(word)
    
end


-- these compile Forth to Lua
function compile_xt(word, xt)
    -- this is a terrible way of doing it... but leave it like this for the moment
    current_word = current_word .. string.format("compiled_word_list['%s']()\n", word)
end

function compile_number(n)
    current_word = current_word .. string.format("push(%f)\n", n)
end



-- Normally quit is the outer interpreter
function raw_quit()
    state_compile = false
    return_stack_ptr = 0
end

function raw_abort()
    stack_ptr = 0
    raw_quit()
end

function convert_number(s)
    -- Why function?
    -- 1. we might want to ensure whole string is number
    -- 2. we also might want to handle negative numbers
    -- 3. tonumber only handles unsigned integers in bases other than 10
    -- 4. we might want to handle % $ # operators of FlashForth
    return tonumber(s, number_base)
end

function compile_num(n)
    compile_raw(string.format("push(%f)", n))
end

function interpret(s)
    input_buffer = s
    input_buffer_index = 1
    repeat        
        local word = get_next_word()
        if word == nil then
            return true
        end
 
        -- notice this doesn't follow forth dictionary order
        local xt = compiled_word_list[word]
        if xt then
            if state_compile and not immediate_word_list[word] then
                compile_xt(word, xt)
            else
                xt()
            end
        else
            local number = convert_number(word)
            if number then
                if state_compile then
                    compile_num(number)
                else
                    push(num)
                end
            else
                raw_quit()
                return false, "Unknown word or number " .. word
            end
        end
    until false
end

-- should be FAST
function get_word_xt(word)
    --find_word_in_dict(word)
    return compiled_word_list[word]
end

-- could this be removed, since it's just a lua function?
function execute_xt(xt)
    if xt then
        xt()
    end
end

-- ( addr -- n )
add_new_word("@", function()
        push(dict[pop()])
    end)

-- ( n addr -- )
add_new_word("!", function()
        local addr = pop()
        dict[addr] = pop()
    end)

