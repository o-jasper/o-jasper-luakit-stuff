--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- Chrome page of all logs. User may do subselection.

require "listview.chromable"

paged_chrome("listview", {
   default_name = "search",
   search = setmetatable({}, metatable_of(listview_search_meta)),
   add = setmetatable({}, metatable_of(listview_add_meta)),
   all = setmetatable({}, metatable_of(listview_all_meta)),
})
