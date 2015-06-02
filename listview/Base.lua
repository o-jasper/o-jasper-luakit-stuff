--  Copyright (C) 01-05-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local c = require("o_jasper_common")
local asset = require("paged_chrome").asset

local config = globals.listview or {}
local ensure = require("o_jasper_common.ensure")

-- Base metatable of templated html page.
return {
   new_remap = {log=1, where=2},
   new_prep = { where = ensure.table },
   new_assert_types = {log="table", where="table"},
   
   repl_pattern = false, to_js = {},
   
   config = function(self) return config end,
   -- NOTE; might say it belongs to paged-chrome, but it provides the freedom to
   --  make it more convenient.
   -- Alternatively "derive-from" the paged-chrome, however, i dont want to,
   -- and that'd push my metatable approach onto others.
   asset = function(self, what, kind)
      return asset(self.where, what .. (kind or ".html"))
   end,
   
   asset_getter = function(self, what, kind)
      return function() return self:asset(what, kind) end
   end,
   
   repl_list = function(self, args, _, _)
      return { title = string.format("%s:%s", self.chrome_name, self.name) }
   end,
}
