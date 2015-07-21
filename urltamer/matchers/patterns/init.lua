local Public = {}

local permissive = require("urltamer.handler").permissive

Public["^$"] = permissive
Public["^luakit://.+"] = permissive
Public["^https?://0.0.0.0"] = permissive

return Public
