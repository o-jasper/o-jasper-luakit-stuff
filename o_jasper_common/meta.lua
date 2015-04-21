-- Jasper den Ouden, placed in public domain.

local function metatable_of(meta)
   local index = {} ---meta.__index = meta

   for k,v in pairs(meta.direct or {}) do  -- TODO remove cases, then remove this.
      if type(v) == "function" then
         index[k] = function(self, ...)
            assert(type(self) == "table", string.format("got(%s): %s", k, self))
            return v(self)(...)
         end
      else
         index[k] = v
      end
   end
   meta.defaults = meta.defaults or {}
   meta.defaults.values = meta.values or {}
   for k,v in pairs(meta.defaults) do index[k] = v end -- TODO remove cases, then this.

   for k,v in pairs(meta) do index[k] = v end

   meta.__index = index
   return meta
end

return metatable_of
