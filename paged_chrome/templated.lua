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
            return c.full_gsub(self.page.repl_pattern,
                               self.page:repl_list(args, view, meta))
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
function Public.templated_page(page, name)
   if page.name then  -- Ensure set name.
      assert( not name or page.name == name )
   else
      page.name = name
   end

   if not page.repl_pattern then  -- Ensure pattern.
      if page.asset then
         page.repl_pattern = page:asset(page.name, ".html")
      else
         page.repl_pattern = Public.asset(page.name, ".html")
      end      
   end
   return setmetatable({page = page}, templated_page_metatable)
end

return Public
