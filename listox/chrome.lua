local tox = require "ffi.tox"

local c = require "o_jasper_common"

local ffi = require "ffi"

local function hexify(list, n)
   local hex = "0123456789ABCDEF"
   local i, n, ret = 0, n or #list, ""
   while i < n do
      local k, l = list[i]%16 + 1, math.floor(list[i]/16) + 1
      ret = ret .. string.sub(hex, k, k+1) .. string.sub(hex, l, l+1)
      i = i + 1
   end
   return ret
end

local html = [[
<h1>Tox{%version_major}.{%version_minor}.{%version_patch}</h1>

<table>
<tr><td>name:</td>   <td>{%self_name}</td></tr>
<tr><td>pubkey:</td> <td><pre>{%self_pubkey}</pre></td></tr>
<tr><td>addr:</td>   <td><pre>{%self_addr}</pre></td></tr>
<tr><td>status:</td> <td>{%self_status_msg}</td></tr>
</table>

<p>{%self_friend_cnt}</p>
]]

local function repl(self)
--   local opts = tox.Opts.new()
--   opts:options_default()
   local comm = self.comm or tox.new() --opts)
   self.comm = comm
   if comm:self_get_name_size() == 0 then
      comm:self_set_name("MIAUW" .. os.date("%c"))
   end
   
   return {
      version_major = tox.version_major(), version_minor = tox.version_minor(), 
      version_patch = tox.version_patch(),
      
      self_name   = comm:self_get_name(),
      self_pubkey = hexify(comm:self_get_public_key(), 32),
      self_addr   = hexify(comm:self_get_address(), 38),
      self_status_msg = comm:self_get_status_message(),

      self_friend_cnt = tonumber(comm:self_get_friend_list_size()),
   }
end

local pages = {
   default_name = "info",
   info = {
      html = function(self)
         return c.apply_subst(html, repl(self))
      end,
      init = false,
   },
}

return { listox = {  chrome_name = "listox", pages = pages,  } }
