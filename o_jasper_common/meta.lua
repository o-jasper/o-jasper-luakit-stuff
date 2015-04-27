-- Jasper den Ouden, placed in public domain.

local copy_table = require("o_jasper_common.other").copy_table

local Public = {}

local function dont_index(_, _)
   error("You have not prepared the metatable for use!")
end

function Public.copy_meta(of)
   local ret = copy_table(of)
   ret.__index = dont_index
   return ret
end

function Public.metatable_of(meta)
   assert(not meta.__index or type(meta.__index) == "function" 
             and not meta.__metatable_of_override,
          "Did you use `copy_meta` properly?")
   local index = {}
   for k,v in pairs(meta) do index[k] = v end
   meta.__index = index
   return meta
end

return Public
