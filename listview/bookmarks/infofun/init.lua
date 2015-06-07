local function index(_, key)
   return require("listview.bookmarks.infofun." .. key)
end
return setmetatable({}, { __index = index })
