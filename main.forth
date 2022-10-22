: love_index2 ( si2 n si1 n -- f ) 
    love
    nip lua@ ( -- si2 n t1 )  
    nip lua@ ( -- f )
;
: love2call ( i*x p si2 n si1 n t -- j*x)
    love_index2 lua_execute
;
: fread ( size name nameLen -- data )
  drop 2 S" read" S" filesystem" love2call
;
: interpret_file lua_nil swap fread drop sinterpret ;

S" utils.forth" interpret_file 
S" unittests.forth" interpret_file
S" forth_terminal.forth" interpret_file

0 variable textx
0 variable texty

: love.draw ( -- )
    300 400 S" hello" love.graphics.print
    320 420 S" goodbye" love.graphics.print
    FT_draw
;

: love.textinput ( t -- )
    FT_textinput
;

: love.keypressed ( key -- )
    FT_keypressed
;

: love.update ( dt -- )
    FT_update
;


\ TODO
\
\ maybe we can make a interactive interpreter here?
\ probably need if (and more!)
\ Why is S" capitals?
\
\ If we store the word a table in the dictionary (as well as a last defined 
\ chunk store - currently called compiled_word_list{})
\ then we can store:
\  * the source code for the word
\  * a copy of the chunk at the time the original was defined
\  * the immediate flag
\  * an inline flag (which would allow inlining the source during compile
\     obviously would stop these words from being redefined - but we could
\     issue a warning.)
\  * allow redefine to work
\  * have a pointer in each to the previous word and therefore have link list 
\    style find - with multiple words
\ * 
\  * add_new_word() can do this work
\
\ Fix compile failures / crash failures - forth should keep going
\ interpret_file should report errors and fail without stopping forth engine
\ Add extra words repeat, while, if, etc.


