--error("Doesnt exist at this point")
local Public = {}

Public.cur_time = require "o_jasper_common.cur_time"
Public.metatable_of = require "o_jasper_common.meta"

for k,v in pairs(require("o_jasper_common.other")) do
   Public[k] = v
end
Public.load_asset = require "o_jasper_common.load_asset"

Public.tableText = require("o_jasper_common.text").tableText

return Public
