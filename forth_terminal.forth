\ Implements a Forth terminal
\ (c) 2021 Rob Probin
\ MIT License, see LICENSE

\ how many bytes
0 variable FT_input_ptr

\ allot, lua_string or lua table?
\ create input_buffer 80 allot
lua{} variable FT_input_bufffer
\ S"" drop variable FT_input_buffer

: FT_init
    \ text = "Type away! -- "

    \ enable key repeat so backspace can be held down to trigger love.keypressed multiple times.
    1 S" setKeyRepeat" S" keyboard" love2call  
;


: FT_textinput ( t -- )
    \ text = text .. t
    drop
;

: FT_update ( dt -- )
    drop
;

: FT_keypressed ( key -- )
    S"backspace" = if
        \ get the byte offset to the last UTF-8 character in the string.
        \ text -1 lua_nil utf8.offset if
        
            \ remove the last UTF-8 character.
            \ string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            \ text = string.sub(text, 1, byteoffset - 1)
        then
    then
;

: FT_draw ( -- )
    \ love.graphics.printf(text, 0, 0, love.graphics.getWidth())
;
