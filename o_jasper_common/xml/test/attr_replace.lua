-- Super-limited-test

local attr_replace = require "o_jasper_common.xml.attr_replace"

local attrs = {
   { tagname="a", fun = function(_, name, val) return name == "rep" and "replaced" or nil end },
   { tagname="b", fun = function(_, name, val) if name == "r" then return false end end },
}

local fr = [[bas<a  a="1">gd<a rep="ska", q="22" rep="xx" r="1"> afa<q a="53454", b="35">sfs<p x="32">fafs</p> <b r="removeme" a="<a>"><img>]]
local to = [[bas<a a="1">gd<a rep="replaced" q="22" rep="replaced" r="1"> afa<q a="53454", b="35">sfs<p x="32">fafs</p> <b a="<a>"><img>]]
assert(attr_replace(attrs, fr) == to)

-- TODO no-changes test.
