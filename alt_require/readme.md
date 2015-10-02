Experimentation with using `load` to record, determine, and/or restrict things.

Basically, it could be a mandatory access control tool, a tool to analyse.

But *also*, in principle, it might be possible to take some arbitrary lua file
and say "you run on this other computer, using http(s) to talk".
(or Tox, or whatever) Indicating just how MAC it could be. (of course,
if they use `io.open` or something, different files may see a different
operating system)

Appears to work for both lua and luajit, but been used and developped
very limitedly.
