decimal 
: emit lua_string_char lua_io.write ;
: type drop lua_io.write ;
: cr 10 emit lua_io.flush ;  
\ replace this . with a routine that prints in the current base
: . lua_io.write ;
: bl 32 ;
: space bl emit ;


\ display the stack
: .s 
    depth 1 + 1 do
        depth i - dstack@ . space
    loop
;

S" STACK============" type cr
0 1 2 3 .s cr
depth . cr
S" =================" type cr


\ : spaces ( bl emit

\ : new{}param ( i*x x -- t ) 
\ lua{} 1 do 
\   
\ loop
\ ;

\ lua{} S" unittest.fth" drop over 1 swap lua!
\ S" read" S" filesystem" love love_index3
\ lua_tcall S" n" drop over lua@ .

