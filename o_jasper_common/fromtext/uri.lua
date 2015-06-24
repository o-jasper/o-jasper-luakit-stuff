local string_split = require("lousy").util.string.split

-- This should be in lib/lousy/uri.lua ?
local Public = {}

-- Thanks to: https://gist.github.com/ignisdesign/4323051
function Public.disannoy_file_url(str)
   assert(type(str) == "string")
   str = string.gsub(str, "\n", "\r\n")
   str = string.gsub(str, "([^%w_-=.:@& ])",
                     function (c) return string.format ("%%%02X", string.byte(c)) end)
   str = string.gsub(str, " ", "+")
   return str
end

function Public.disannoy_filename(file)
   assert(type(file) == "string")
   local function handler(c)
      local respond = {
         [" "] = "_", ["\n"] = "_", ["\t"] = "_", ["\0"] = "",
      }
      if respond[c] then return respond[c] end
      return string.format("%%%02X", string.byte(c))
   end
   return string.gsub(file, "([^%w_-=.,:@])", handler)
end

function Public.url_to_pathlist(str)
   local got = {}
   local list = string_split(str)
   assert(#list > 0)
   assert(string.match(#list[1], "^.+:$"), "Protocol doesnt end with `:`")
   list[1] = string.gsub(list[1], #(list[1]) - 1)
   for _, el in pairs(list) do
      if el ~= "" then table.insert(got, Public.disannoy_file_url(el)) end
   end
   return got
end

function Public.url_to_path(str)
   return table.concat(Public.url_to_pathlist(str), "/")
end

function Public.domain_of_uri(uri)
   if string.match(uri, "^file://.+") then
      return "file://"
   else
      local _, s = string.find(uri, "//")
      if s then
         local e, _ = string.find(uri, "/", s+1)
         e = e or #uri + 1
         return string.sub(uri, s + 1, e - 1)
      else
         return "unknown"
      end
   end
end

return Public
