-- Shows readme functions and/or 

local c = require "o_jasper_common"

local this = {}

function this.maybe_new(path, file, dir)
   print(file)
   for _, pat in pairs({"[.]jpg", "[.]jpeg",
                        "[.]gif", "[.]bmp", "[.].png", "[.]svg" }) do
      if string.match(string.lower(file), pat) then
         return setmetatable({ path=path, file=file }, this)
      end
   end
end

function this:priority()
   return 1 -- For now.. should be context-dependent..
end

function this:html()  -- TODO not allowed to touch local shit..
   local fp = self.path .. "/" .. self.file
   return string.format([[<a href="file:/%s"><img src="file://%s"></a>]], fp, fp)
end

return c.metatable_of(this)
