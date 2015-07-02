local c = require "o_jasper_common"

local This = c.copy_table(require "various.mirror.base")

-- Basically it is :dump, but with a pre-calculated path.
-- Still loads *all* the assets besides.
function This:do_uri(uri, clobber, window)
   local path = self:clear_path(self:path(uri))
   local fd = assert(io.open(path, "w"), "couldnt open")
   fd:write(window.view:eval_js("document.documentElement.outerHTML"))
   fd:close()
end

return This


