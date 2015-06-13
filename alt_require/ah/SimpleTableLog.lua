-- Record into tables.

local ar = require "alt_require"
local c  = require "o_jasper_common.meta"

local This = c.copy_meta(require "alt_require.ah.SimpleBase")
This.__name = "alt_require.ah.TableLog"

This.record_require_file = true
This.new_defaults.recorded = {}
This.new_defaults.recorded_require = {}

function This:init()
   if self.recurse then
      self.override.require = ar.alt_require(self)
   end
   if self.record_require_file then
      -- Otherwise it will just access the existing one.
      local oldrequire = self.override.require
      self.override.require = function(str)
         self.recorded_require[str] = (self.recorded_require[str] or 0) + 1
         return oldrequire(str)
      end
   end
end

function This:meta(where)
   local now = self.recorded[where] or {}
   self.recorded[where] = now
   return {  -- Putting in variable for use in recursing use.
      __index = function(_, key)
         now[key] = (now[key] or 0) + 1
         return (not self.forbid[key]) and (self.override[key] or _ENV[key])
      end,
      __pairs = function(_) return pairs(_ENV) end,
   }
end

return c.metatable_of(This)
