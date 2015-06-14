local ar = require "alt_require"
local c  = require "o_jasper_common.meta"

local e = {}
e.loadstring = loadstring
e.coroutine = coroutine
e.unpack = unpack
e.xpcall = xpcall
e.setmetatable = setmetatable
e.dofile = dofile
e.pcall = pcall
e.load = load
e.rawlen = rawlen
e.rawget = rawget
e.os = os
--e.package = package  -- Recurses, breaks `c.copy_meta`
e.getmetatable = getmetatable
e.arg = arg
e.tostring = tostring
--e._G = G  -- Seems like bad idea.
e.bit32 = bit32
e.debug = debug
e.utf8 = utf8
e.io = io
e.string = string
e.tonumber = tonumber
e.math = math
e.select = select
e.assert = assert
e.print = print
e.table = table
e.next = next
e.rawset = rawset
e.require = require
e.pairs = pairs
e.collectgarbage = collectgarbage
e.module = module
e.loadfile = loadfile
e._VERSION = VERSION
e.rawequal = rawequal
e.error = error
e.type = type
e.ipair = ipair

local This = {
   __name = "alt_require.ah.SimpleBase",
   new_defaults = { env = e },
}

function This:require(what) return ar.alt_require(self)(what) end

return c.metatable_of(This)
