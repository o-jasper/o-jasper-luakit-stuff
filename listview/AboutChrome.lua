local c = require("o_jasper_common")

local mod_AboutChrome = {
   repl_list = function(self, args)
      return setmetatable(
         {   title = string.format("%s:%s", self.chrome_name, self.name),
         },
         {__index=function(kv, key)
             if self.log.values[key] then
                 return self.log.values[key]
             elseif key == "raw_summary" then
                return c.tableText(self.log.values,
                                   "&nbsp;&nbsp;", "","<br>")
             end
         end
         })
   end,
}
return c.metatable_of(c.copy_meta(require "listview.Base", mod_AboutChrome))
