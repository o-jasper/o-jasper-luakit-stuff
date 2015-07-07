local Public = {}

function Public.dir(path)
   local j = string.find(path, "/[^/]+$")
   return string.sub(path, 1, j)
end

function Public.file(path)
   return string.sub(string.match(path, "/[^/]+$") , 2)
end

return Public
