-- Makes chrome paged-ier.
-- TODO/NOTE: wanna basically imitate a library for servers.

local Public ={}

local c = require "o_jasper_common"

function Public.asset(what, kind)  -- TODO get rid of listview.. somehow..
   return load_asset("assets/" .. what .. (kind or ".html"))
      or "COULDNT FIND ASSET"
end

local templated_page_metatable = {
   __index = function(self, key)
      local vals = {
         html = function(args, view, meta)
            local pattern = self.page.repl_pattern
            if not pattern then  -- TODO just have `templated_page` do this?
               if self.page.asset then
                  pattern = self.page:asset(self.page.name, ".html")
               else
                  pattern = Public.asset(self.page.name, ".html")
               end
            end
            return c.full_gsub(pattern, self.page:repl_list(args, view, meta))
         end,
         init = function(_, view, _, _)
            if not self.done then  -- Just attach javascript as soon as possible.
               for name, fun in pairs(self.page.to_js) do
                  view:register_function(name, fun(self.page, name))
               end
               self.done = true
            end
         end,
      }
      return vals[key]
   end,
   __newindex = function(self, key, to) -- Setting is passed on.
      self.page[key] = to
   end,
}

-- Makes the above page-object      based on templates instead. Requires a:
-- `repl_pattern`                   template in which replacements take place.
--                                  if none -> a simularly named asset is used.
-- `repl_list(args, view, meta)`,   method returning replacement rules.
-- `to_js`                          lua functions accessible to javascript.
function Public.templated_page(page)
   assert(page)
   return setmetatable({page = page}, templated_page_metatable)
end

return Public
