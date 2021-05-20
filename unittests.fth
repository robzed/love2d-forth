
S" start unit tests" type cr 

S" 3 + 2 = " type 3 2 + . cr
S" love type=" type love lua_type count type cr

S" *" dup . type cr

S" depth = " type depth . cr

S" >" type
33 emit
S" <" type cr

S" MAIN.FTH" type
S" -file" type cr
S" -read" type cr

S" end unit tests" type cr 
