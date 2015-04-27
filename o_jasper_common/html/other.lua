
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

return Public
