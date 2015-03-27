--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- Chrome page of all logs. User may do subselection.

require "listview.chromable"
require "paged_chrome"

paged_chrome("listview", {
   default_name = "search",
   search = templated_page(setmetatable({}, metatable_of(listview_search_meta))),
   add    = templated_page(setmetatable({}, metatable_of(listview_add_meta))),
   all    = templated_page(setmetatable({}, metatable_of(listview_all_meta))),
})
