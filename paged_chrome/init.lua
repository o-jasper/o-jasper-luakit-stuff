-- Makes chrome paged-ier.

local chrome = require("chrome")
local lousy = require("lousy")

paged_chrome_dict = {}

-- Each page has an `init(view, meta)` and `html(view,meta)`
function paged_chrome(chrome_name, pages)
   paged_chrome_dict[chrome_name] = pages
   chrome.add(chrome_name,
              function (view, meta)
                 local use_name = lousy.util.string.split(meta.path, "/")[1]
                 local pages = paged_chrome_dict[chrome_name]
                 local page = pages[use_name]
                 if not page then
                    use_name = pages.default_name
                    page = pages[use_name]
                    --assert(page, string.format("MIAUW %s %s %s", use_name, meta.path, lousy.util.string.split(meta.path, "/")[1]))
                 end
                 -- TODO.. just use meta.path as the path!?
                 local use_uri = string.format("luakit://%s/%s", chrome_name, use_name)
                 page.chrome_name = chrome_name
                 page.name = use_name
                 view:load_string(page.html(view, meta), use_uri)
                 
                 function on_first_visual(view, status)
                    -- Wait for new page to be created
                    if status ~= "first-visual" then return end
                    page.init(view, meta)
                    -- Hack to run-once
                    view:remove_signal("load-status", on_first_visual)
                 end
                 view:add_signal("load-status", on_first_visual)
              end)
end

require "o_jasper_common"

function asset(what, kind)
   return load_asset("listview/assets/" .. what .. (kind or ".html"))
      or "COULDNT FIND ASSET"
end

-- Makes the above page-object based on templates instead. Requires a:
-- `repl_pattern` template in which replacements take place.
-- `repl_list`,   replacement rules table.(may be in meta)
-- `to_js`        lua functions accessible to javascript.
local templated_page_metatable = {
   __index = function(self, key)
      local vals = {  
         html = function(view, meta)
            return full_gsub(self.page.repl_pattern or asset(self.page.name, ".html"),
                             self.page.repl_list(view, meta))
         end,
         init = function(view, _)
            for name, fun in pairs(self.page.to_js) do
               view:register_function(name, fun(self.page, name))
            end
         end,
      }
      return vals[key]
   end,
   __newindex = function(self, key, to) -- Setting is passed on.
      self.page[key] = to
   end,
}

function templated_page(page)
   x = {page=page}
   setmetatable(x, templated_page_metatable)
   return x
end
