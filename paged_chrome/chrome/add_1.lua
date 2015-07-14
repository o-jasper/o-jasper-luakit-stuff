local chrome = require "chrome"
local string_split = require("lousy").util.string.split

local Suggest = require "paged_chrome.Suggest"

-- Each page has an `init(args)` and `html(args)`
return function(pageset)
   local chrome_name = pageset.chrome_name
   local pages = pageset.pages
   assert(type(chrome_name) == "string", string.format("%s not string", chrome_name))
   chrome.add(chrome_name,
              function (view, meta)
                 local use_path = meta.path
                 local use_name = string_split(use_path, "/")[1]
                 local page  = pages[use_name]
                 if not page or type(page) == "string" then
                    use_name = page or pages.default_name
                    use_path = chrome_name .. "/" .. use_name
                    page = pages[use_name]
                 end
                 -- (in case each has state that doesnt otherwise work, generate a new page
                 --  each time)
                 meta.view  = view
                 meta.whole = true
                 if type(page) == "function" then page = page(meta) end
                 page.chrome_name = chrome_name
                 page.page_list = pages
                 local use_uri = "luakit://" .. chrome_name .. "/" .. use_path
                 view:load_string((page.html or Suggest.html)(page, meta),
                                  use_uri)

                 local function on_first_visual(view, status)
                    meta.view = view
                    -- Either the provided one or the suggested one.
                    local _ = page.on_first_visual and page:on_first_visual(meta) or
                       Suggest.on_first_visual(page, meta)
                    
                    -- Hack to run until first visual.
                    if status == "first-visual" then
                       view:remove_signal("load-status", on_first_visual)
                    end
                 end
                 view:add_signal("load-status", on_first_visual)
              end)
end
