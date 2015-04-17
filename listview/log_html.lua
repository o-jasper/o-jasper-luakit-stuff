--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

require "o_jasper_common"

local ot = require "o_jasper_common.html.other"
local tt = require "o_jasper_common.html.time"

--- TODO better to add them to the other one?

-- Put it into the metamethod.
function msg_meta.direct.ms_t(self)
   return math.floor(self[self.logger.values.time]*self.logger.values.timemul)
end

function msg_meta.direct.tagsHTML(self)
   return ot.tagsHTML(self.tags, self.html_state.tagsclass) 
end

function msg_meta.direct.dateHTML(self)
   return tt.dateHTML(self.html_state, self.ms_t)
end

function msg_meta.direct.timemarks(self)
   return tt.timemarks(self.html_state, self.ms_t)
end

-- Single entry.
function html_msg(listview, state)
   return function (index, msg)
      msg.html_state = state
      msg.index = index
      -- TODO..shouldnt be needed.
      for _, k in pairs({"title", "desc", "uri", "origin"}) do
         msg[k] = msg[k] or ""
      end
      -- TODO put in more stuff.
      return string.gsub(listview.asset("parts/show_1"), "{%%(%w+)}", msg)
   end
end

function html_msg_list(listview, data, config)
   local pass_state = { 
      last_time = cur_time_ms(),
      config = config or {}  -- TODO config stuff in listview?!
   }
   return html_list(data, html_msg(listview, pass_state))
end
