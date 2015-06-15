local ar = require "alt_require"
local c  = require "o_jasper_common.meta"

local e = {}  -- NOTE: "escaping" stuff probably in here!
e.loadstring = loadstring  -- An escape
e.coroutine = coroutine
e.unpack = unpack
e.xpcall = xpcall
e.setmetatable = setmetatable
e.dofile = dofile
e.pcall = pcall
e.load = load  -- An escape
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
   new_defaults = { env = e, loaded={} },
}

function This:init()
   assert(self.loaded)
   if self.recurse then
      self.env.require = self:require_fun()
   end
   if self.record_require_file then
      -- Otherwise it will just access the existing one.
      local oldrequire = self.env.require
      self.env.require = function(file)
         self:record_require(file)
         return oldrequire(file)
      end
   end
end

function This:envfun(file) return setmetatable({}, self:meta(file)) end

function This:require_fun(envfun)
   local envfun = envfun or self.envfun
   return function(file)
      local ret = self.loaded[file]
      if not retgot then
         local file_path = ar.alt_findfile(file)
         ret = file_path and loadfile(file_path, nil, envfun(self, file))()
         self.loaded[file] = ret
      end   
      return ret
   end
end
function This:require(what) return self:require_fun()(what) end

return c.metatable_of(This)
