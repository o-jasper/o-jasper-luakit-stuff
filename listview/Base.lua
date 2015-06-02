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
local this = {
   new_remap = {log=1, where=2},
   new_prep = { where = ensure.table },
   new_assert_types = {log="table", where="table"},
   
   repl_pattern = false, to_js = {},
}

function this:config() return config end
-- NOTE; might say it belongs to paged-chrome, but it provides the freedom to
--  make it more convenient.
-- Alternatively "derive-from" the paged-chrome, however, i dont want to,
-- and that'd push my metatable approach onto others.
function this:asset(what, kind)
   return asset(self.where, what .. (kind or ".html"))
end
   
function this:asset_getter(what, kind)
   return function() return self:asset(what, kind) end
end
   
function this:repl_list(args)
   error("Thou shalt not use the base repl list.")
   --print("Base repl_list being used? how come?", args)
   --return { title = string.format("%s:%s", self.chrome_name, self.name) }
end

return c.metatable_of(this)
