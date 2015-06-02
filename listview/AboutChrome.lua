local c = require("o_jasper_common")

local this = c.copy_meta(require "listview.Base")

function this:repl_list(args)
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
end

return c.metatable_of(this)
