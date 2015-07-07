-- Turns `search` objects into infofun objects. Memoizes.

local c = require "o_jasper_common"

local memoize = {}

return function(class)
   -- Return memoizeized version.
   local got = memoize[class]
   if got then return got end

   got = c.copy_meta(class)
   
   got.__name = "infofun_ize(" .. class.__name .. ")"
   function got:repl(args)
      local ret = class.repl(self, args)
      -- Search done at replacement rather than javascript-time.
      ret.list_internal = self:html_list(self:total_query(""):result(), true)
      return ret
   end

   function got:repl_pattern(args)
      -- Go for the body instead of including-headers.
      return self:asset("body/" .. self.name .. ".html")
   end
   
   assert(got.html)

   got = c.metatable_of(got)
   memoize[class] = got
   return got
end

