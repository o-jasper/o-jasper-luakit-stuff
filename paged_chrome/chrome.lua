local chrome = require "chrome"
local string_split = require("lousy").util.string.split

local paged_chrome_dict = {}

local Suggest = require "paged_chrome.Suggest"

-- Each page has an `init(args, view, meta)` and `html(args, view, meta)`
local function paged_chrome(chrome_name, pages)
   paged_chrome_dict[chrome_name] = pages
   chrome.add(chrome_name,
              function (view, meta)
                 local use_path = meta.path
                 local use_name = string_split(use_path, "/")[1]
                 local pages = paged_chrome_dict[chrome_name]
                 local page  = pages[use_name]
                 if not page then
                    use_name = pages.default_name
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
                 view:load_string(page.html and page:html(meta) or Suggest.html(page, meta),
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

return paged_chrome
