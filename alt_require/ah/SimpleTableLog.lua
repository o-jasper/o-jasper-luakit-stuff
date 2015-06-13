-- Record into tables.
-- (here just for example.)

local ar = require "alt_require"
local c  = require "o_jasper_common.meta"

local SimplePrintLog = require "alt_require.ah.SimplePrintLog"
local This = c.copy_meta(SimplePrintLog)
This.__name = "alt_require.ah.TableLog"

This.new_defaults.recorded = {}
This.new_defaults.recorded_require = {}

function This:record_require(str)
   self.recorded_require[str] = (self.recorded_require[str] or 0) + 1
end
function This:record(where, key)
   local now = self.recorded[where]
   now[key] = (now[key] or 0) + 1
end

function This:meta(where)
   self.recorded[where] = self.recorded[where] or {}
   return SimplePrintLog.meta(self, where)
end

return c.metatable_of(This)
