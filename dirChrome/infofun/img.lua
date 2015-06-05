-- Shows readme functions and/or 

local c = require "o_jasper_common"

local this = {}

function this.maybe_new(path, file, dir)
   for _, pat in pairs({"[.]jpg$", "[.]jpeg$",
                        "[.]gif$", "[.]bmp$", "[.]png$", "[.]svg$" }) do
      if string.match(string.lower(file), pat) then
         return setmetatable({ path=path, file=file }, this)
      end
   end
end

function this:priority()
   return 1 -- TODO For now.. should be context-dependent.. and need see-what-you-select.
end

function this:html()  -- TODO not allowed to touch local shit..
   local fp = self.path .. "/" .. self.file
   local got = c.base64.enc_file(fp)
   local format = string.match(self.file, "[.][%a]+")
   if got and format then
      return string.format([[%s<img src="data:image/%s;base64,%s", alt="%s">]],
         fp, string.sub(format, 2), got, fp)
   end
end

return c.metatable_of(this)
