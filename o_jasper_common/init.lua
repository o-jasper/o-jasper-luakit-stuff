--error("Doesnt exist at this point")
local function index(d, key)
   assert(type(key) == "string")
   return require("o_jasper_common." .. key)
end

local Public = setmetatable({}, {__index = index})

for k,v in pairs(require "o_jasper_common.meta")   do Public[k] = v end
for k,v in pairs(require "o_jasper_common.other") do Public[k] = v end
for k,v in pairs(require "o_jasper_common.load_asset") do Public[k] = v end
for k,v in pairs(require "o_jasper_common.text") do Public[k] = v end

return Public
