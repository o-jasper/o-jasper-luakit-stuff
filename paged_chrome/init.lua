-- Makes chrome paged-ier.

local chrome = require("chrome")

require "o_jasper_common"

function asset(what, kind)
   return load_asset("listview/assets/" .. what .. (kind or ".html"))
      or "COULDNT FIND ASSET"
end

page_meta = {
   default = {},
   values = {
      -- to_js is the list of functions that are exported into JS.
   },
   
   direct = {
      init = function(self) return function(view, meta)
            for name, fun in pairs(self.values.to_js) do
               view:register_function(name, fun(self, name))
            end
      end end,
      repl_pattern = function(self) return asset(self.name, ".html") end,
      -- AFAICS this one completely context-dependent.
      --  (Can also go more direct and replace html)
      repl_list    = function(self) return function(view, meta)
            error("Oh dear, didnt replace this?")
      end end,

      html = function(self) return function(view, meta)
            return full_gsub(self.repl_pattern, self.repl_list(view, meta))
      end end,
   },
   determine = {}
}

paged_chrome_dict = {}

function paged_chrome(chrome_name, pages)
   paged_chrome_dict[chrome_name] = pages
   chrome.add(chrome_name,
              function (view, meta)
                 local use_name = lousy.util.string.split(meta.path, "/")[1]
                 local pages = paged_chrome_dict
                 local page = pages[use_name]
                 if not page then
                    use_name = pages.default_name
                    page = pages[use_name]
                    assert(page)
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
