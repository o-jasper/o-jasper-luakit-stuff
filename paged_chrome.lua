-- Makes chrome paged-ier.

local chrome = require("chrome")

function paged_chrome(chrome_name, pages)
   chrome.add(chrome_name,
              function (view, meta)
                 local use_name = lousy.util.string.split(meta.path, "/")[1]
                 local page = pages[use_name]
                 if not page then
                    use_name = pages.default_name
                    page = pages[use_name]
                    assert(page)
                 end
                 local use_uri = string.format("luakit://%s/%s", chrome_name, use_name)
                 page.chrome_name = chrome_name
                 page.name = use_name
                 view:load_string(page.html(page, view, meta), use_uri)
                 
                 function on_first_visual(view, status)
                    -- Wait for new page to be created
                    if status ~= "first-visual" then return end
                    page.init(page, view, meta)
                    -- Hack to run-once
                    view:remove_signal("load-status", on_first_visual)
                 end
                 view:add_signal("load-status", on_first_visual)
              end)
end
