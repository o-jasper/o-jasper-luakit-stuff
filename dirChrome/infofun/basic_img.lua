-- Shows readme functions and/or 

local c = require "o_jasper_common"

local this = {}

function this.maybe_new(path, file)
   for _, pat in pairs({"[.]jpg$", "[.]jpeg$",
                        "[.]gif$", "[.]bmp$", "[.]png$", "[.]svg$" }) do
      if string.match(string.lower(file), pat) then
         return setmetatable({ path=path, file=file }, this)
      end
   end
end

function this:priority()
   return -0.5 -- TODO context-dependence?
end

function this:html()
   local fp = self.path .. "/" .. self.file
   local got = c.base64.enc_file(fp)
   local format = string.match(self.file, "[.][%a]+")
   if got and format then
      -- TODO have a function defined somewhere so when i dont need to
      -- base54-encode anymore, i only need to change it there.
      -- TODO, also, this can take a little while..
      return string.format([[<img src="data:image/%s;base64,%s", alt="%s">]],
         string.sub(format, 2), got, fp)
   end
end

return c.metatable_of(this)
