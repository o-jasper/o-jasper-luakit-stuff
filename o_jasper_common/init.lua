--error("Doesnt exist at this point")
local function index(d, key)
   assert(type(key) == "string")
   return require("o_jasper_common." .. key)
end

local this = setmetatable({}, {__index = index})

for k,v in pairs(require "o_jasper_common.meta")   do this[k] = v end
for k,v in pairs(require "o_jasper_common.other") do this[k] = v end
for k,v in pairs(require "o_jasper_common.load_asset") do this[k] = v end

for k,v in pairs(require "o_jasper_common.text") do this[k] = v end

return this
