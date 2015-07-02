-- Does not work because wget seems to fail at --page-requisites.
-- mailing lists are too annoying to me. Thunderbird doesnt even recognize them
-- for you. Does any software bloody sort them for you?
-- Fucking backward technology.

local conf = globals.wget_mirror or {}
local mirror_dir = conf.mirror_dir or (os.getenv("HOME") .. "/.luakit/mirror/")

local This = {}

function This:do_uri(uri, clobber)
   luakit.spawn("mkdir -p " .. mirror_dir) -- TODO better way of making directory.
   -- E = adjust−extension, k = convert−links,
   -- p = page−requisites.
   -- nv = lower verbosity.
   luakit.spawn(string.format("wget --directory-prefix %s  %s -nv --page-requisites -k %s",
                              mirror_dir, clobber and "-nc" or "", uri))

end

function This:dir(uri)
   if string.match(uri, "^http://") then uri = string.sub(uri, 8) end
   if string.match(uri, "^https://") then uri = string.sub(uri, 9) end
   return "file://" .. mirror_dir .. "/" .. uri
end

return This
