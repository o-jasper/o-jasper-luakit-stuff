local require_index = require "o_jasper_common.require_index"
return setmetatable({}, { __index = require_index("urltamer.handler") })
