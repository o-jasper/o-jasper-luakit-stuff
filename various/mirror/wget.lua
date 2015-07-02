-- Not-for-use.

-- Does not work because wget seems to fail at --page-requisites.
-- mailing lists are too annoying to me. Thunderbird doesnt even recognize them
-- for you. Does any software bloody sort them for you?
-- Fucking backward technology.

local c = require "o_jasper_common"

local This = c.copy_table(require "various.mirror.base")

function This:do_uri(uri, clobber)
   local path = self:clear_path(self:page_path(uri))
   luakit.spawn_sync("mkdir -p " .. self:mirror_dir()) -- TODO better way of making directory.
   -- E = adjust−extension, k = convert−links,
   -- p = page−requisites.
   -- nv = lower verbosity.
   -- It will make the path for us.
   luakit.spawn(string.format("wget --directory-prefix %s -E %s -nv --page-requisites -k %s -o %s",
                              self:mirror_dir(), clobber and "-nc" or "", uri. path))
   return path
end

function This.new() return This end  -- Dont really care for that.

return This
