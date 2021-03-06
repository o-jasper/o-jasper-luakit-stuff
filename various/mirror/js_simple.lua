local c = require "o_jasper_common"

local This = c.copy_meta(require "various.mirror.base")

-- Basically it is :dump, but with a pre-calculated path.
-- Still loads *all* the assets besides.
function This:do_uri(uri, clobber, window)
   local path = self:clear_path(self:page_path(uri))
   local fd = assert(io.open(path, "w"), string.format("couldnt open %q %s", path, fd))
   fd:write(window.view:eval_js("document.documentElement.outerHTML"))
   fd:close()
   return path
end

return c.metatable_of(This)
