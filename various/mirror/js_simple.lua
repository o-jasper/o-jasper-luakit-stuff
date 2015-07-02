local c = require "o_jasper_common"

local This = c.copy_table(require "various.mirror.base")

-- Basically it is :dump, but with a pre-calculated path.
-- Still loads *all* the assets besides.
function This:do_uri(uri, clobber, window)
   local path = self:clear_path(self:page_path(uri))
   local fd = io.open(path, "w")
   assert(fd, string.format("couldnt open %q %s", path, fd))
   fd:write(window.view:eval_js("document.documentElement.outerHTML"))
   fd:close()
   return path
end

return This


