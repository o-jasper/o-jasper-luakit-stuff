--error("Doesnt exist at this point")
local Public = {}

Public.cur_time = require "o_jasper_common.cur_time"
for k,v in pairs(require "o_jasper_common.meta")   do Public[k] = v end
for k,v in pairs(require("o_jasper_common.other")) do Public[k] = v end
Public.load_asset = require "o_jasper_common.load_asset"

Public.full_gsub = require "o_jasper_common.full_gsub"

Public.tableText = require("o_jasper_common.text").tableText

return Public
