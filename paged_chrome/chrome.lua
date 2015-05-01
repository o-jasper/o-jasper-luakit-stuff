local chrome = require("chrome")
local string_split = require("lousy").util.string.split

local paged_chrome_dict = {}

-- Each page has an `init(args, view, meta)` and `html(args, view, meta)`
local function paged_chrome(chrome_name, pages)
   paged_chrome_dict[chrome_name] = pages
   chrome.add(chrome_name,
              function (view, meta)
                 local use_name = string_split(meta.path, "/")[1]
                 local pages = paged_chrome_dict[chrome_name]
                 local page = pages[use_name]
                 if not page then
                    use_name = pages.default_name
                    page = pages[use_name]
                 end
                 -- TODO.. just use meta.path as the path!?
                 local use_uri = string.format("luakit://%s/%s", chrome_name, use_name)
                 page.chrome_name = chrome_name
                 page.page_list = pages
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

return paged_chrome
