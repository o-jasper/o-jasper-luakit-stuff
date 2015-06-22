--  Copyright (C) 23-06-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local c = require("o_jasper_common")

local BaseSearch = require "listview.BaseSearch"
local This = c.copy_meta(BaseSearch)

local infofun_lib = require "sql_help.infofun"

function This:side_infofun()
   return self:config().side_infofun or {}
end

function This.to_js:html_of_id()
   return function(id)
      local entry = self.log:get_id(id)
      local list = infofun_lib.entry_thresh_priority(self.log, entry, 
                                                     self:side_infofun(), -1)
      infofun_lib.priority_sort(list, self.config().priority_override)
      local html = self:list_to_html(list, {})
      return html and #html > 0 and html  -- Makes sense.
   end
end

function This:js_listupdate(list, as_msg)
   local ret = BaseSearch.js_listupdate(self, list, as_msg)

   local infofuns = self:side_infofun()
   if true then --infofuns and #infofuns > 0 then
      local infos = {}  -- Collect relevant information.
      for _, entry in pairs(list) do
         infofun_lib.entry_thresh_priority(self, entry, infofuns, 0, infos)
      end
      -- Sort the relevant info by importance.
      infofun_lib.priority_sort(infos, self:config().priority_override)
      ret.info = self:list_to_html(infos, {})
   end      
   return ret
end

return c.metatable_of(This)
