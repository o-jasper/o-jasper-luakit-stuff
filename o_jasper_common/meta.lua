-- Jasper den Ouden, placed in public domain.

local copy_table = require("o_jasper_common.other").copy_table

local Public = {}

local function dont_index(_, _)
   error("You have not prepared the metatable for use!")
end

function Public.copy_meta(of, mod)
   assert(of, "Nothing to copy")
   assert(not mod, "Dont do mod anymore, makes sub-tables too messy.")
   local oldindex = of.__index  -- TODO not handy.
   of.__index = nil
   local ret = copy_table(of)
   of.__index = oldindex

   ret.__index = dont_index
   ret.__name = "unset_name_from_" .. of.__name
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
   meta.__name = meta.__name or "unset"
   if not meta.new then
      meta.new = function(initial)
         local function msg(str, ...)
            local ret = ""
            for k,v in pairs(initial) do ret = ret .. string.format("%s: %s\n", k,v) end
            return string.format("(%s)\n", meta.__name) .. ret .. string.format(str, ...)
         end
         initial = initial or {}
         -- Set-by-index.
         for k,v in pairs(meta.new_remap or {}) do
            assert( not (initial[v] and initial[k]) )
            initial[v] = initial[k]
            initial[k] = nil
         end
         if meta.new_prep and meta.new_prep_whole then
            initial = meta.new_prep_whole(initial)
         end
         assert(type(initial) == "table")
         assert(getmetatable(initial) ~= meta, "Default `new` not to be called as member.")

         -- Changers for particular inputs.
         for k, fun in pairs(meta.new_prep or {}) do
            initial[k] = type(fun) == "function" and fun(initial[k])
         end
         -- Defaults. _Don't_ use if just adding a value to the metatable is good.
         -- That is, only if it is a table that the user can change, and it
         -- shouldnt be the metatable-table.
         for k, fun in pairs(meta.new_defaults or {}) do
            initial[k] = initial[k] == nil and
               (type(fun) == "function" and fun(initial[k]) or fun) or
               initial[k]
         end

         -- Assert stuff about it.
         for k,tp in pairs(meta.new_assert_types or {}) do
            if type(tp) == "function" then
               assert(tp(initial[k]))
            elseif tp == "exists" then
               assert(initial[k])
            else
               assert(type(initial[k]) == tp,
                      msg("Type mismatch, expected %s to have type %s but had %s", 
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
