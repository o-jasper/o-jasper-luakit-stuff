-- But one way to use metatables.
function metatable_of(meta)
   -- Ensure there is something in there.
   meta.defaults  = meta.defaults or {}
   meta.direct    = meta.direct or {}
   meta.determine = meta.determine or {}
   meta.values    = meta.values or {}

   meta.defaults.values = meta.values
   
   if not meta.metatable then
      meta.metatable = {
         __index = function(self, key)
            local got = meta.defaults[key]
            if got ~= nil then return got end
            
            local got = meta.direct[key]
            if got then return got(self, key) end
            
            local determiner = meta.determine[key]
            if determiner then  -- To be determined by functions.
            local val = determiner(self, key)
            rawset(self,key, val)
            return val
            end
            if meta.otherwise then
               return meta.otherwise(self, key)
            else
               error(string.format("Doesnt seem to lead to the index.. %q", key))
            end
         end,
         meta=meta
      }
   end
   return meta.metatable
end
