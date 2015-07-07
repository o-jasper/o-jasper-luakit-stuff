
local Public = {}

local conf = globals.urltamer or {}

-- TODO configurations.
local reload_require = conf.reload_require -- or "userconf.urltamer"

local function require_reload(what)
   package.loaded[what] = nil
   return require(what)
end

-- Easier integration of changes.
function Public.reload()
   Public.patterns = require_reload("urltamer.matchers.patterns")
   Public.straight_domains = require_reload("urltamer.matchers.straight_domains")
   
   if reload_require then
      for k,v in pairs(require_reload(reload_require .. ".patterns") or {}) do
         Public.patterns[k] = v
      end
      for k,v in pairs(require_reload(reload_require .. ".straight_domains") or {}) do
         Public.straight_domains[k] = v
      end
   end
end

Public.reload()

return Public
