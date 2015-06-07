local function index(_, key)
   return require("listview.infofun." .. key)
end
return setmetatable({}, { __index = index })
