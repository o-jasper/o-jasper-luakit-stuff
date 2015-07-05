local c = require "o_jasper_common"

local attr_replace = require "o_jasper_common.xml.attr_replace"

local This = c.copy_meta(require "various.mirror.base")
This.__name = "js_readhtml"

function This:localize_src_fun()
   return function(_, name, val)
      if name == "src" then
         local path = self:clear_path(self:path(val))
         luakit.spawn(string.format("wget -nv %s -o %s", val, path))
      end
   end
end

function This:attr_replace()
   return {
      {tagname="img",    fun=self:localize_src_fun()},
      {tagname="style",  fun=self:localize_src_fun()},
      {tagname="script", fun=self:localize_src_fun()},
   }
end

function This:do_uri(uri, clobber, window)
   local path = self:clear_path(self:page_path(uri))

   -- Doesnt seem doable to change the page from within..
   local html = attr_replace(window.view:eval_js("document.documentElement.outerHTML"),
                             self:attr_replace())

   -- Write it.
   local fd = assert(io.open(path, "w"), "couldnt open")
   fd:write(html)
   fd:close()
   return path
end

return c.metatable_of(This)


