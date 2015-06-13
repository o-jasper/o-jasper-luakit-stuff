local ar = require "alt_require"
local c  = require "o_jasper_common.meta"

local This = {
   __name = "alt_require.ah.SimpleBase",
   new_remap = { "override", "forbid", "require_file", "recursive" },
   new_defaults = { override = {}, require_override = {}, forbid = {}, },
   recurse = true,
}

function This:require(what) return ar.alt_require(self)(what) end

function This:forbidden(key) return self.forbid[key] end

return c.metatable_of(This)
