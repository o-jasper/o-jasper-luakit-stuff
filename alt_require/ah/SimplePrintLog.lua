-- Record by printing.

local ar = require "alt_require"
local c  = require "o_jasper_common.meta"

local This = c.copy_meta(require "alt_require.ah.SimpleBase")
This.__name = "alt_require.ah.PrintLog"

This.record_require_file = true

function This:init()
   if self.recurse then
      self.override.require = ar.alt_require(self)
   end
   if self.record_require_file then
      -- Otherwise it will just access the existing one.
      local oldrequire = self.override.require
      self.override.require = function(str)
         print("require:", str)  -- Add the print.
         return oldrequire(str)
      end
   end
end

function This:meta(where)
   return {  -- Putting in variable for use in recursing use.
      __index = function(_, key)
         print(where, key)
         return (not self.forbid[key]) and (self.override[key] or _ENV[key])
      end,
      __pairs = function(_) return pairs(_ENV) end,
   }
end

return c.metatable_of(This)
