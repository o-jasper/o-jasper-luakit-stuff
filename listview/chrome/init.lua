--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- Chrome page of all logs. User may do subselection.

require "listview.chromable"
require "listview.log_html"

require "paged_chrome"

local log = new_log(capi.luakit.data_dir .. "/msgs.db")

paged_chrome("listview", {
   default_name = "search",
   search = templated_page(listview_chrome(log, "search", "listview")),
   add    = templated_page(listview_chrome(log, "add",    "listview")),
   all    = templated_page(listview_chrome(log, "all",    "listview")),
})
