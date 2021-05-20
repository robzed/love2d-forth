: love_index3 ( si2 n si1 n t -- f ) 
    nip lua@ ( -- si2 n t1 )  
    nip lua@ ( -- f )
;
: love3call ( i*x p si2 n si1 n t -- j*x)
    love_index3 lua_execute
;
: fread ( size name nameLen -- data )
  drop 2 S" read" S" filesystem" love love3call
;
: interpret_file lua_nil swap fread drop sinterpret ;

S" utils.fth" interpret_file 
S" unittests.fth" interpret_file


0 variable textx
0 variable texty

: love.draw ( -- )
    300 400 S" hello" love.graphics.print
    320 420 S" goodbye" love.graphics.print
;

\ maybe we can make a interactive interpreter here?

: love.textinput drop ;

