
local Public = {}

-- TODO take iterator as argument instead.
function Public.tagsHTML(tags, class)
   class = (class == "") and "" or class and " class=" .. class or [[ class="msg_tag"]]
   local ret = {}
   for _, tag in pairs(tags) do
      table.insert(ret, string.format("<span%s>%s</span>", class, tag))
   end
   return table.concat(ret, ", ")
end

function Public.table(tab, format)
   local row = (format or {}).row or
      [[%s<tr><td class="table_key">%s</td><td class="table_val">%s</td></tr>]]
   local ret = ""
   for k, v in pairs(tab) do ret = string.format(row, ret, k, v) end
   return ret
end

return Public
