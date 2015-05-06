-- Makes chrome paged-ier.
-- TODO/NOTE: wanna basically imitate a library for servers.

local Public ={}

local c = require "o_jasper_common"

function Public.asset(what, kind)  -- TODO get rid of listview.. somehow..
   return c.load_asset("assets/" .. what .. (kind or ".html"))
end

local real_asset = require "paged_chrome.asset"

local templated_page_metatable = {
   __index = function(self, key)
      local vals = {
         html = function(args, view)
            local repl_list = self.page:repl_list(args, view)
            
            if self.page.where_list then
               local function asset_too(obj, key)
                  local got = obj.rl[key]
                  if got then
                     return got
                  else
                     for _, path in pairs(self.page.where_list) do
                        local got = c.load_asset(path .. "/assets/" .. key .. ".html")
                        if got then return got end
                     end
                  end
               end
               repl_list = setmetatable({rl=repl_list}, {__index = asset_too })
            end
            return c.full_gsub(self.page.repl_pattern, repl_list)
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
-- `repl_list(args, view)`,   method returning replacement rules.
-- `to_js`                          lua functions accessible to javascript.
function Public.templated_page(page, name)
   if page.name then  -- Ensure set name.
      assert( not name or page.name == name )
   else
      assert(name)
      page.name = name
   end

   if not page.repl_pattern then  -- Ensure pattern.
      if page.asset then
         page.repl_pattern = page:asset(page.name, ".html")
      else
         page.repl_pattern = Public.asset(page.name, ".html")
      end
   end
   -- The page object contains the entire interface it is based on.(still available)
   return setmetatable({page = page}, templated_page_metatable)
end

return Public
