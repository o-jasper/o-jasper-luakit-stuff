-- Record by printing.
-- (here just for example.)

local c  = require "o_jasper_common.meta"

local This = c.copy_meta(require "alt_require.ah.SimpleBase")
This.__name = "alt_require.ah.PrintLog"

This.record_require_file = true

This.new_remap = { "env", "forbid", "require_file", "recursive" }
This.new_defaults.forbid = {}
This.recurse = true

function This:forbidden(key) return self.forbid[key] end

function This:record_require(str)
   print("require:", str)  -- Add the print.
end
function This:record(where, key)
   print(where, key)
end

function This:meta(where)
   return {  -- Putting in variable for use in recursing use.
      __index = function(_, key)
         self:record(where, key)
         return (not self.forbid[key]) and self.env[key]
      end,
      -- No good, doesnt check if forbidden.
      -- __pairs = function(_) return pairs(self.env) end,
   }
end

return c.metatable_of(This)
