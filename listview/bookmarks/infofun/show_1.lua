local c = require "o_jasper_common"

local This = c.copy_meta(require "listview.infofun.show_1")

function This.tab_repl:data_uri()
   if not self.e.data_uri or self.e.data_uri == "" then
      return [[<span class="minor">(no data uri)</span>]]
   else
      return self.e.data_uri
   end
end

function This.tab_repl:title()  -- TODO history should have This too.
   return self.e.title or self.e.uri or "(no title)"
end

return c.metatable_of(This)
