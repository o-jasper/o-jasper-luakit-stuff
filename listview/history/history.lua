--  Copyright (C) 27-03-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

require "listview.entry_html"  -- TODO... Want this later.

HistoryEntry = require "listview.history.HistoryEntry"
History = require "listview.history.History"

local db = require("history").db
history = setmetatable({ db = db }, History)