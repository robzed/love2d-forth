-- Support works to make things easier
--
-- Copyright 2021 Rob Probin, released under MIT license, see file LICENSE
-- 

-- Forth true is all bits set
-- Forth false is all bit clear
function convert_to_forth_bool(flag)
    if flag then return -1 else return 0 end
end

-- pack for Lua 5.1
function pack(...)
    return { n = select("#", ...), ... }
end


