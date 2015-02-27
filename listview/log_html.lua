--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.


local html = lousy.load_asset("listview/assets/show_1.html") or ""

local function tags_html(tags) return function(class)
   class = class == "" and "" or class and " class=" .. class or [[ class="msg_tag"]]
   local ret = {}
   for _, tag in pairs(tags) do
      table.insert(ret, string.format("<span%s>%s</span>", class, tag))
   end
   return table.concat(ret, ", ")
end end

msg_meta.direct.realtime_tags_html = function(self) tags_html(self.rt_tags()) end
msg_meta.direct.rt_tags_html = msg_meta.direct.realtime_tags_html

msg_meta.direct.tags_html = function(self) tags_html(self.tags) end

local does = {tags=true}

function html_msg()
   return function (index, msg)
      if does.tags then msg.tagsHtml = tags_html(msg.tags)() end
      msg.index = index
      for _, k in pairs({"title", "desc", "uri", "origin"}) do 
         msg[k] = msg[k] or ""
      end
      -- TODO put in more stuff.
      return string.gsub(html, "{%%(%w+)}", msg)
   end
end

function html_msg_list(data) return html_list(data, html_msg()) end
