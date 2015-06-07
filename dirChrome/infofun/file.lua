-- Shows readme functions and/or 

local config_from = (globals.dirChrome or {}).infofun or {}
-- Better not use `config.html`, add the asset.
local config = config_from.file or config_from.basic_file or {}

local c = require "o_jasper_common"
local lfs = require "lfs"

local this = {}

function this.maybe_new(path, file)
   if not string.match(file, "^[.]#.+") then
      return setmetatable({ path=path, file=file }, this)
   end
end

function this:priority()
   return 0
end

function this:repl(asset_fun)

   local function dates(attrs, format)
      local have = {}
      for _, name in pairs{"access", "change", "modification"} do
         local same = nil
         for k,v in pairs(have) do
            if v == attrs[name] then
               same = k
            end
         end
         if same then
            have[name .. " {%_and} " .. same] = attrs[name]
            have[same] = nil
         else
            have[name] = attrs[name]
         end
      end
      local ret = ""
      for k,time in pairs(have) do
         ret = ret .. 
            string.format(
               "<tr><td>%s%s:</td><td>%s</td></tr>", -- TOOD use asset fun
               k,
               string.find(k, "{%_and}") and "{%_minor_same}" or "",
               os.date(format or "%c", time)
            )
      end
      return ret
   end
   
   local funs = {
      slashifdir = function() return mode == "directory" and "/" or " " end,

      dates = function(attrs) return dates(attrs) end,

      other = function(attrs)
         local ret, do_which = {}, {"rdev", "ino", "blocks",
                                    "nlink", "uid", "blksize", "gid", "permissions"}
         for _,k in pairs(do_which) do
            table.insert(ret, string.format("<b>%s</b>:%s", k, attrs[k]))
         end
         return table.concat(ret, ", ")
      end,

      default = function(_, _, key)
         return string.match(key, "^[/_.%w]+$") and asset_fun(key)
      end,
   }
   local pattern_funs = {
      ["^date_"] = function(attrs, _, key)
         local inside = string.match(key, "_[%w]+")
         local time = attrs[string.sub(inside, 2)]
         if type(time) == "number" then
            local fmt = string.match(key, "_[%w%%]+$")
            return os.date(fmt == inside and "%c" or string.sub(fmt, 2), time)
         end
      end,

      ["^dates_"] = function(attrs)
         return dates(attrs, string.sub(key, 7))
      end,
   }
   local attrs = lfs.attributes(self.path .. "/" .. self.file)
   assert(attrs, "Couldnt get attributes of(?):" .. self.path .. "/" .. self.file)
   attrs.file = self.file
   attrs.path = self.path
   attrs["_and"] = [[<span class="minor">&</span>]]
   attrs._minor_same = [[<span class="minor">(same)</span>]]
   return c.repl(attrs, nil, attrs, funs, pattern_funs)
end

this.asset_file = "parts/show_elaborate.html"
function this:repl_pattern(asset_fun)
   return config.html or asset_fun(self.asset_file)
end

function this:html(asset_fun)
   return c.apply_subst(self:repl_pattern(asset_fun), self:repl(asset_fun))
end

return c.metatable_of(this)
