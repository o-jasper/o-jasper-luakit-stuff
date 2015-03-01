-- Makes chrome paged-ier.

local chrome = require("chrome")

function paged_chrome(chrome_name, pages)
   chrome.add(chrome_name,
              function (view, meta)
                 local dir_split = lousy.util.string.split(meta.path, "/")
                 local use_name = dir_split[1]
                 local page = pages[use_name]
                 if not page then
                    use_name = "default"
                    page = page.default
                 end
                 local use_uri = string.format("luakit://%s/%s", chrome_name, use_name)
                 view:load_string(page.html(meta, dir_split), use_uri)
                 
                 function on_first_visual(view, status)
                    -- Wait for new page to be created
                    if status ~= "first-visual" then return end
                    page.init(view, meta, dir_split)
                    -- Hack to run-once
                    view:remove_signal("load-status", on_first_visual)
                 end
                 view:add_signal("load-status", on_first_visual)
              end)
end
