local libfile  = "toxcore" --"/usr/lib/libtoxcore.so"  -- TODO locate them better.

if globals then
   local config = globals.ffi_tox or {}
   libfile  = config.libfile  or libfile
end

-- The inbuild stuff from luajit.. So it requires luajit at the moment!
local ffi = require("ffi")

assert(ffi, [[Need `require "ffi"` to work, luajit has it inbuild, lua afaik not.]])

-- NOTE: how it works seems bad style. Something in the _global_ state from
-- ffi.cdef goes into the lib somehow.
ffi.cdef(require "ffi.tox.tox_api")
local lib = ffi.load(libfile)

return lib
