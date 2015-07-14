local string_split = require "o_jasper_common.string_split"

local initial = "a/b/c/d/e/f/g/h/i"

assert(table.concat(string_split(initial, "/"), "/") == initial)
