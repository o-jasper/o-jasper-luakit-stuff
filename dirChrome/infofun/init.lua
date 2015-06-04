local function index(_, key)
   return require("dirChrome.infofun." .. key)
end
return setmetatable({}, {__index = index})
