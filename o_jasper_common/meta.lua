-- Jasper den Ouden, placed in public domain.

local copy_table = require("o_jasper_common.other").copy_table

local Public = {}

local function dont_index(_, _)
   error("You have not prepared the metatable for use!")
end

function Public.copy_meta(of, mod)
   assert(not mod, "Dont do mod anymore, makes sub-tables too messy.")
   local ret = copy_table(of)
   ret.__index = dont_index
   ret.new = nil
   return ret
end

function Public.metatable_of(meta)
   assert(meta ~= nil, "Dont have a value, perhaps accidentally using global value.")
   assert(meta, "meta == false??")
   assert(not meta.__index or type(meta.__index) == "function" 
             and not meta.__metatable_of_override,
          "Did you use `copy_meta` properly?")
   local index = {}
   if not meta.new then
      meta.new = function(initial)
         -- Set the whole thing.
         for k,v in pairs(meta.new_remap) do
            assert( not (initial[v] and initial[k]) )
            initial[k] = initial[v]
            initial[v] = nil
         end
         if meta.new_prep and meta.new_prep_whole then
            initial = meta.new_prep_whole(initial)
         end
         assert(type(initial) == "table")
         assert(getmetatable(initial) ~= meta, "Default `new` not to be called as member.")

         -- Changers for particular inputs.
         for k, fun in pairs(meta.new_prep or {}) do
            initial[k] = fun(initial[k])
         end
         -- Assert stuff about it.
         for k,tp in pairs(meta.new_assert_types or {}) do
            if type(tp) == "function" then
               assert(tp(initial[k]))
            elseif tp == "exists" then
               assert(initial[k])
            else
               assert(type(initial[k]) == tp,
                      string.format("Type mismatch, expected %s to have type %s but had %s", 
                                    k, tp, type(initial[k])))
            end
         end
         local ret = setmetatable(initial, meta)
         if meta.init then
            ret:init()
         end
         return ret
      end
   end
   for k,v in pairs(meta) do index[k] = v end
   meta.__index = index
   return meta
end

return Public
