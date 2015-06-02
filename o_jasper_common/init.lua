--error("Doesnt exist at this point")
local this = {}

this.cur_time = require "o_jasper_common.cur_time"
this.ensure = require "o_jasper_common.ensure"
this.from_text = require "o_jasper_common.from_text"

for k,v in pairs(require "o_jasper_common.meta")   do this[k] = v end
for k,v in pairs(require "o_jasper_common.other") do this[k] = v end
for k,v in pairs(require "o_jasper_common.load_asset") do this[k] = v end

this.full_gsub = require "o_jasper_common.full_gsub"

for k,v in pairs(require "o_jasper_common.text") do this[k] = v end

return this
