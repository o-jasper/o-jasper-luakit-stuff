local this = c.copy_meta(require "listview.Search")

function this:repl_list(args)
   local ret = listview.Search.repl_list(self, args)
   ret.above_title = [[<br><span class="warn">This is just thrown together quickly,
the other bookmarks is the "serious" one.</span>]]
   return ret
end

return c.metatable_of(this)