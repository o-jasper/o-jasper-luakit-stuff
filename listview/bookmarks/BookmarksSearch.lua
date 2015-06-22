local c = require "o_jasper_common"
local listview = require "listview"

local This = c.copy_meta(listview.Search)

function This:config() return (globals.listview or {}).bookmarks or globals.listview or {} end

function This:infofun()
   return self:config().infofun or {require "listview.bookmarks.infofun.show_1"}
end

-- Want the adding-entries js api too.
This.to_js = c.copy_table(This.to_js, require("listview.bookmarks.Enter").to_js)

local plus_cmd_add = require "listview.bookmarks.common".plus_cmd_add

function This:repl(args, view, meta)
   local got = listview.Search.repl(self, args, view, meta)
   
   got.above_title = self:asset("parts/enter_span.html")
   got.right_of_title = [[&nbsp;&nbsp;
<button id="toggle_add_gui" style="width:13em;"onclick="set_add_gui(!add_gui)">BUG</button><br>
]]
   got.after = [[<script type="text/javascript">{%js/bookmarks.js}</script>
<script type="text/javascript">{%js/bookmarks_init.js}</script>
]]

   plus_cmd_add(got, self.log)
   return got
end

return c.metatable_of(This)
