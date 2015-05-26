--  Copyright (C) 01-05-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- TODO this is a bit wonky..

local c = require("o_jasper_common")

local config = globals.listview or {}

local asset = require("paged_chrome").asset

-- Base metatable of templated html page.
return {
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
