local c = require "o_jasper_common"

local OldShow = require "listview.infofun.show_1"
local This = c.copy_meta(OldShow)

function This.tab_repl:security_info(state)
   local sec, http = self.e.isSecure, self.e.isHttpOnly
   local function inconsistent(str)
      return string.format("inconsistent; %s;\nisSecure=%d and isHttpOnly=%d", str or "",
                           sec, http)
   end
   if sec < 0   or sec > 1 or
      http < 0 or http > 1      
   then
      return inconsistent("value size")
   elseif sec == 1 then
      if http == 1 then
         return inconsistent("both secure and http")
      else
         return "via http<b>s<b>"
      end
   elseif http == 1 then
      return "via http"
   else
      return " "
   end
end

-- TODO need to give it a config that works nicely..
-- (also, why does it like 1970 a lot? checking for zero)
function This.tab_repl:resay_expiry(state)
   -- Last `true` means it wont touch state.
   if self.e.expiry == 0 then
      return [[<span class="minor">(until closes)</span>]]
   else
      return c.html.resay_time(state, self.e.expiry,
                               (state.conf.expiry_resay or {}).long, true)
   end
end

function This.tab_repl:expiry_left()
   if self.e.expiry == 0 then
      return [[<span class="minor">(until closes)</span>]]
   else
      return c.html.delta_t_html(self.e.expiry - c.cur_time.s())
   end
end

function This.tab_repl:value() 
   return self.e.value ~= "" and self.e.value or
      [[<span class="minor">(zero-length-string)</span> ]]
end

local string_split = require("lousy.util").string.split

function This.tab_repl:resay_host_path(state)
   local hp = state.host_path or {}
   
   if hp.host == self.e.host and hp.path == self.e.path then
      return " "  -- No change, dont print any.
   else  -- Otherwise, just be so crude to say everything again.
         -- (perhaps instead minor-ize the parts that are the same)
      state.host_path = { host=self.e.host, path=self.e.path }
      return string.format("<b>%s ;= %s</b><br>", self.e.host, self.e.path)
   end
end

-- repl just uses the above.

return c.metatable_of(This)
