local tox = require "ffi.tox"
local paged_chrome = require"paged_chrome.chrome"

local ffi = require "ffi"

local function hexify(list, n)
   local h = "0123456789ABCDEF"
   local i, n, ret = 0, n or #list, ""
   while i < n do
      local k, l = list[i]%16 + 1, math.floor(list[i]/16) + 1
      ret = ret .. string.sub(h, k, k+1) .. string.sub(h, l, l+1)
      i = i + 1
   end
   return ret
end

local pages = {
   default_name = "info",
   info = {
      html = function()
         --print(tox.new)
         local opts = tox.Opts.new()
         opts:options_default()
         local comm = tox.new(opts)
         if comm:self_get_name_size() == 0 then
            comm:self_set_name("MIAUW" .. os.date("%c"))
         end
         local ret= string.format("%d.%d-%d<br>%q<br>%s<br>",
                                  tox.version_major(), tox.version_minor(), 
                                  tox.version_patch(),
                                  comm:self_get_name(),
                                  hexify(comm:self_get_public_key(), 32))
         return ret
      end,
      init = false,
   },
}

paged_chrome("listox", pages)
