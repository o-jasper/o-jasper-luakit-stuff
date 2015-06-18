-- Shows readme functions and/or 

local c = require "o_jasper_common"
local html = c.html

local lfs = require "lfs"

local This = {}

function This.maybe_new(_, entry)
   return setmetatable({ e=entry }, This)
end

function This:priority()
   return 1
end

local function datetab(ms_t)
   return os.date("*t", math.floor(ms_t/1000))
end

This.tab_repl = {
   tagsHTML = function (self, state)
      if self.e.values.taggings then
         return html.tagsHTML(self.e:tags(), state.tagsclass)
      else
         return " "
      end
   end,
   
   dateText = function(self) return os.date("%c", self.e:ms_t()/1000) end,
   -- TODO tad primitive...
   dateHTML = "{%dateText}",
   
   dayname = function(self) return html.day_names[datetab(self.e:ms_t()).wday] end,
   monthname = function(self) return html.day_names[datetab(self.e:ms_t()).wday] end,
   
   -- NOTE: the delta/resay cases only make sense when sorting by time.
   -- TODO: perhaps the state/state.config should tell This and have proper behavior.
   delta_dateHTML = function(self, state)
      return html.delta_dateHTML(state, self.e:ms_t())
   end,
   
   timemarks = function(self, state)
      return html.time(state, self.e:ms_t())
   end,
   
   resay_time = function(self, state)
      return html.resay_time(state, self.e:ms_t(), (state.config.resay or {}).long)
   end,
   
   short_resay_time = function(self, state)
      local config = (state.config.resay or {}).short or {
         {"year", "Year {%year}"},
         {"yday", "{%month}/{%day} {%short_dayname}"},
         init = " ", nochange = " ", }
      return html.resay_time(state, self.e:ms_t(), config)
   end,

   identifier = function(self, _)
      return c.int_to_string(self.e[self.e.values.idname])
   end,
   
   markdown_desc = {
      function(self)
         -- TODO.. ... discount isnt co-operating..
         --  strange, luajit works, but luakit compiled with it doesnt.
         -- local discount = require("discount") --package.loaded("discount")
         local markdown = require "markdown"
         if markdown then
            return markdown(self.e.desc or ""), 2
         else
            return self.e.desc, 1
         end
      end,
   },
   
   table = function(self)
      return c.html.table(self.e)
   end,

   default = function(self, _, key)
      local got = self.e[key]
      if got then  -- Gsub does not do zero-length output.
         return got == "" and " " or got
      else
         return string.match(key, "^[/_.%w]+$") and self.asset_fun(key)
      end
   end,
}

for k in pairs(os.date("*t", 0)) do This.tab_repl[k] = "{%time_" .. k .. "}" end

This.tab_pat = {
   ["^date_"] = function(attrs, _, key)
      local inside = string.match(key, "_[%w]+")
      local time = attrs[string.sub(inside, 2)]
      if type(time) == "number" then
         local fmt = string.match(key, "_[%w%%]+$")
         return os.date(fmt == inside and "%c" or string.sub(fmt, 2), time)
      end
   end,
   
   ["^time_"] = function(self, state, key)
      local got = datetab(self.e:ms_t())[string.sub(key, 6)]
      if got then
         return got
      else
         return os.date("%" .. string.sub(key, 6), math.floor(self.e:ms_t()/1000))
      end
   end,
   
   ["^dates_"] = function(attrs)
      return dates(attrs, string.sub(key, 7))
   end,
}

function This:repl(state, asset_fun)
   return c.repl(self, state, {}, self.tab_repl, self.tab_pat)
end

This.asset_file = "parts/show_1.html"
function This:repl_pattern(asset_fun) return asset_fun(self.asset_file) end

function This:html(state, asset_fun)
   state.config = state.config or {}
   self.asset_fun = asset_fun
   return c.apply_subst(self:repl_pattern(asset_fun), self:repl(state, asset_fun))
end

return c.metatable_of(This)
