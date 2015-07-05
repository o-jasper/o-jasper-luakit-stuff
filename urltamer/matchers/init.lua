
local Public = {}

-- TODO configurations.
local alt_dir = os.getenv("HOME") .. ".luakit/urltamer/"

Public.straight_domains = require "urltamer.matchers.straight_domains"

-- Note: patterns is iterated. 
Public.patterns = require "urltamer.matchers.patterns"

function Public.reload()
   -- TODO 
   local sd_dir = alt_dir .. "straight_domains/"
   if lfs.attributes(sd_dir) then
      for file in lfs.dir(sd_dir) do
         if string.match(file, "[%w]+.lua") then  -- Lua file.
            -- List of responses.
            for k,v in pairs(loadfile(sd_dir .. file)()) do
               Public.straight_domains[k] = v
            end
         end
      end
   end
   -- Yep... the same.. inefficient.
   local pat_dir = alt_dir .. "patterns/"
   if lfs.attributes(pat_dir) then
      for file in lfs.dir(pat_dir) do
         if string.match(file, "[%w]+.lua") then  -- Lua file.
            -- List of responses.
            for k,v in pairs(loadfile(pat_dir .. file)()) do
               Public.patterns[k] = v
            end
         end
      end
   end
end

Public.reload()

return Public
