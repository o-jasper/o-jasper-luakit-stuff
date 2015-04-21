-- Jasper den Ouden, placed in public domain.

-- But one way to use metatables.
--function metatable_of(meta)
--   -- Doesnt have any concept of setting things.
--   -- (will use the normal table -setting mechanism)
--   meta.defaults  = meta.defaults or {}  -- Default value if not set.(does not set them)
--   meta.direct    = meta.direct or {}    -- Values returned-as-function.(setting overrides)
--   meta.determine = meta.determine or {} -- Run-once-stored determining values.
--   meta.values    = meta.values or {}    -- Values that have to explicitly refered to.
--
--   meta.defaults.values = meta.values  -- (this is how you get at the values)
--   
--   if not meta.metatable then
--      meta.metatable = {
--         __index = function(self, key)
--            local got = meta.defaults[key]
--            if got ~= nil then return got end
--            
--            local got = meta.direct[key]  -- Difference is that this one is called.
--            if got then return got(self, key) end
--            
--            local determiner = meta.determine[key]
--            if determiner then  -- To be determined by functions.
--               local val = determiner(self, key)
--               rawset(self,key, val)
--               return val
--            end
--            if meta.otherwise then
--               return meta.otherwise(self, key)
--            else
--               error(string.format("Doesnt seem to lead to the index.. %q", key))
--            end
--         end,
--         meta=meta
--      }
--   end
--   return meta.metatable
--end

function metatable_of(meta)
   local index = {} ---meta.__index = meta

   for k,v in pairs(meta.direct or {}) do  -- TODO remove cases, then remove this.
      if type(v) == "function" then
         index[k] = function(self, ...)
            assert(type(self) == "table")
            return v(self)(...)
         end
      else
         index[k] = v
      end
   end
   for k,v in pairs(meta.defaults or {}) do index[k] = v end -- TODO remove cases, then this.
   index.values = index.values or {}

   for k,v in pairs(meta) do index[k] = v end

   meta.__index = index
   return meta
end
