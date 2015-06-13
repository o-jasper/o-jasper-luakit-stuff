local ar = require "alt_require"
local c  = require "o_jasper_common.meta"

local This = { __name = "alt_require.ah.SimpleBase", }

function This:require(what) return ar.alt_require(self)(what) end

return c.metatable_of(This)
