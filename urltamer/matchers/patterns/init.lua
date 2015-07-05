local Public = {}

local permissive = require("urltamer.handler").permissive

Public["^$"] = permissive
Public["^luakit://.+"] = permissive

return Public
