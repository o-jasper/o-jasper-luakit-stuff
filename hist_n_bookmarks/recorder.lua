require "hist_n_bookmarks"

webview.init_funcs.record_hist = function (view)
    -- Add items & update visit count
    view:add_signal("load-status", function (_, status)
        -- Don't add history items when in private browsing mode
        if view.enable_private_browsing then return end

        if status == "committed" then
           history.see({uri=view.uri, last_time=os.time()})
        end
    end)
    -- Update titles
    view:add_signal("property::title", function ()
        -- Don't add history items when in private browsing mode
        if view.enable_private_browsing then return end

        local title = view.title
        if title and title ~= "" then
           history.see({uri=view.uri, title=title, last_time=os.time()})
        end
    end)
end
