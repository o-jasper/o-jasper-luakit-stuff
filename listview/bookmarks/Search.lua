
local this = c.copy_meta(require "listview.Search")

-- Want the adding-entries js api too.
this.to_js = c.copy_table(listview.Search.to_js, mod_Enter.to_js)

local plus_cmd_add = require "listview.bookmarks.common".plus_cmd_add

function this:repl_list(args, view, meta)
   local got = listview.Search.repl_list(self, args, view, meta)
   got.above_title = self:asset("parts/enter_span")
   got.right_of_title = [[&nbsp;&nbsp;
<button id="toggle_add_gui" style="width:13em;"onclick="set_add_gui(!add_gui)">BUG</button><br>
]]
   got.after = [[<script type="text/javascript">{%bookmarks.js}</script>
<script type="text/javascript">{%bookmarks_init.js}</script>
]]
      
   plus_cmd_add(got, self.log)
   return got
end

return c.metatable_of(this)
