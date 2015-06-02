--  Copyright (C) 11-05-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local c = require("o_jasper_common")
local this = c.copy_meta(require("listview.Base"))

this.to_js = {
   do_it = function(self) return function ()
         require("listview.bookmarks.import")(require("bookmarks").db,
                                              require "listview.bookmarks.bookmarks")
   end end,
}

return c.metatable_of(this)
