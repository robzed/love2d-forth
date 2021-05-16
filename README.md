
**UNDER DEVELOPMENT**

# Goals

1. To make Love2D middleware that allows using the Love2D runtime and libraries
with the Forth language.


# How to use

See main.fth for examples. In theory Forth files are the only thing you should
have to change. In reality, it's not as straight forward as this because this is
still a work in progress.

# To Do Next

I'd like to provide examples of an interactive Forth shell, editting definition
while it's runnng, printing graphics and playing sounds. 


# What Word Set?

Nearly all of my previous Forths have mostly been based on the ANS wordset, 
partially because the words are documented (if sometimes cryptic because
of the adstraction to allow differnet underlying models).

Since one of the sub-goals is to allow VForth-Next virtual development (for
the Spectrum Next) this has been prioritised during development, but if 
necessary we can add the core words for other dialects.

However, exact match isn't necessarily required.

VForth-Next is FIG-Forth based. 

Jupiter Ace is Forth-79 (At time of writing this Forth, I just finished reading
the Juputer Ace FORTH Programming manual by Steven Vickers for the first time. 
Very good book, by the way).

It probably wouldn't be hard to make it ANS Forth.

https://forth-standard.org/standard/diff


# List of Love 2D API supported.

Very minimal. See love2dwords.lua and main.lua.




# Internals 

Rather than a direct/indirect/threaded forth, we compile to native Lua.

We could do this even for 'interpret' mode - but don't.

Some of the primatives (especially compile_xt) is really naive. 





# Other Lua Forths?

I looked at these Lua Forth's briefly before prototyping this code, but decided 
to play with making my own forth:

* https://github.com/IonoclastBrigham/firth    (MIT license)
* https://github.com/vifino/luaforth      (MIT license)
* https://github.com/SoniEx2/Stuff/tree/master/lua/Forth   (MIT license)
* https://gist.github.com/operator-DD3/6b24abad594ac56acc6c    (No license)
* http://angg.twu.net/miniforth-article.html     (No license) (from http://angg.twu.net/luaforth.html)

You should take a look at these and see if they are viable for any purpose you 

