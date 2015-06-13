-- Record by printing.
-- (here just for example.)

local ar = require "alt_require"
local c  = require "o_jasper_common.meta"

local This = c.copy_meta(require "alt_require.ah.SimpleBase")
This.__name = "alt_require.ah.PrintLog"

This.record_require_file = true

This.new_remap = { "override", "forbid", "require_file", "recursive" }
This.new_defaults = { override = {}, require_override = {}, forbid = {}, }
This.recurse = true

function This:forbidden(key) return self.forbid[key] end

function This:record_require(str)
   print("require:", str)  -- Add the print.
end
function This:record(where, key)
   print(where, key)
end

function This:init()
   if self.recurse then
      self.override.require = ar.alt_require(self)
   end
   if self.record_require_file then
      -- Otherwise it will just access the existing one.
      local oldrequire = self.override.require
      self.override.require = function(str)
         self:record_require(str)
         return oldrequire(str)
      end
   end
end

function This:meta(where)
   return {  -- Putting in variable for use in recursing use.
      __index = function(_, key)
         self:record(where, key)
         return (not self.forbid[key]) and (self.override[key] or _ENV[key])
      end,
      -- No good, doesnt check if forbidden.
      -- __pairs = function(_) return pairs(_ENV) end,
   }
end

return c.metatable_of(This)
