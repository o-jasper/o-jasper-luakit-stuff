-- Makes chrome paged-ier.
-- TODO/NOTE: wanna basically imitate a library for servers.

local Public ={ paged_chrome_dict = {} }

local lousy = require("lousy")

local chrome = require("chrome")
-- Each page has an `init(args, view, meta)` and `html(args, view, meta)`
function Public.paged_chrome(chrome_name, pages)
   Public.paged_chrome_dict[chrome_name] = pages
   chrome.add(chrome_name,
              function (view, meta)
                 local use_name = lousy.util.string.split(meta.path, "/")[1]
                 local pages = Public.paged_chrome_dict[chrome_name]
                 local page = pages[use_name]
                 if not page then
                    use_name = pages.default_name
                    page = pages[use_name]
                 end
                 -- TODO.. just use meta.path as the path!?
                 local use_uri = string.format("luakit://%s/%s", chrome_name, use_name)
                 page.chrome_name = chrome_name
                 page.name = use_name
                 view:load_string(page.html(nil, view, meta), use_uri)
                 
                 function on_first_visual(view, status)
                    page.init(nil, view, meta)
                    -- Hack to run until first visual.
                    if status == "first-visual" then
                       view:remove_signal("load-status", on_first_visual)
                    end
                 end
                 view:add_signal("load-status", on_first_visual)
              end)
end

local c = require "o_jasper_common"

function Public.asset(what, kind)  -- TODO get rid of listview.. somehow..
   return load_asset("assets/" .. what .. (kind or ".html"))
      or "COULDNT FIND ASSET"
end

-- Makes the above page-object      based on templates instead. Requires a:
-- `repl_pattern`                   template in which replacements take place.
--                                  if none -> a simularly named asset is used.
-- `repl_list(args, view, meta)`,   method returning replacement rules.
-- `to_js`                          lua functions accessible to javascript.
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

function Public.templated_page(page)
   assert(page)
   return setmetatable({page = page}, templated_page_metatable)
end

return Public
