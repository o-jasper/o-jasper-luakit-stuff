-- Jasper den Ouden, placed in public domain.

local function metatable_of(meta)
   local index = {}
   for k,v in pairs(meta) do index[k] = v end
   meta.__index = index
   return meta
end

return metatable_of
