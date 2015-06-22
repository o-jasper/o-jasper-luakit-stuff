--  Copyright (C) 01-05-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local c = require("o_jasper_common")

local config = globals.listview or {}
local ensure = require("o_jasper_common.ensure")

-- Base metatable of templated html page.
local mod = {
   __name = "listview.Base",

   new_remap = {"name", "log", "append_where"},
   new_prep = { append_where = ensure.table },
   new_assert_types = {log="table", append_where="table"},
   
   repl_pattern = false, to_js = {},
}

local This = c.copy_meta(require "paged_chrome.Suggest")
for k,v in pairs(mod) do This[k] = v end

function This:config() return config end

function This:init()
   local config = self:config()

   self.where = self.where or config.assets_where or {}
   if self.append_where then
      for _, w in pairs(self.append_where) do
         table.insert(self.where, w)
      end
      self.append_where = nil
   end
end

return c.metatable_of(This)
