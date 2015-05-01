--  Copyright (C) 01-05-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local c = require("o_jasper_common")

local config = globals.listview or {}

-- Base metatable of templated html page.
return {
      repl_pattern = false, to_js = {},

      config = function(self) return config end,

-- TODO.. seems like something that might belong in `paged_chrome`.
      asset = function(self, what, kind)
         assert(type(self) == "table")
         if type(self.where) == "string" then self.where = {self.where} end
         local after = "/assets/" .. what .. (kind or ".html")
         for _, w in pairs(self.where) do
            local got = c.load_asset(w .. after)
            if got then return got end
         end
         return c.load_asset("listview" .. after) or "COULDNT FIND ASSET"
      end,
      asset_getter = function(self, what, kind)
         return function() return self:asset(what, kind) end
      end,

      repl_list_meta = function(self, args)
         return {
            __index = function(kv, key)
               if string.match(key, "[/_%w]") then
                  return self:asset(key, "")
               end
            end,
         }
      end,

      repl_list = function(self, args, _, _)
         return setmetatable(
            {  title = string.format("%s:%s", self.chrome_name, self.name),
            }, self:repl_list_meta())
      end,
}
