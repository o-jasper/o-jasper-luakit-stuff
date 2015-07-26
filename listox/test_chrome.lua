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

<p>Friendcnt: {%self_friend_cnt}</p>
]]

local function repl(self)
--   local opts = tox.Opts.new()
--   opts:options_default()
   local comm = self.comm or tox.new() --opts)
   self.comm = comm
   if comm:self_get_name_size() == 0 then
      comm:self_set_name("MIAUW" .. os.date("%c"))
   end
   
   -- uint32_t tox_friend_add_norequest(Tox *tox, const uint8_t *public_key, TOX_ERR_FRIEND_ADD *error);

   local ids = {}
   for _, el in pairs(contacts:all_contacts()) do
      local fid = comm:friend_add_norequest(el.pubkey)
      ids[el.id] = fid  -- Remember the mapping.
      -- tox-side name.
      comm:friend_set_name(fid, el.alias)

      -- comm:friend_get_name(id) -- assuming as-stored, actually.(not used)
   end

   comm:callback_self_connection_status(function(_, status)
         print(status)  -- Probably 0 none, 1 tcp, 2 udp
   end)

   -- _Just_ is used to update names.
   comm:callback_friend_name(function(_, fid, name, name_len)
         assert(#name == name_len)
         if ids[fids] then
            local contact = contacts:get_id(ids[fid])
            if contact:alias_changable_by_friend_self() then
               -- TODO in there, possibly record alias changes.
               contacts:change_alias(contact.id, name)
            end
            -- tox-side name.
            comm:friend_set_name(fid, name)
         end
   end)
   comm:callback_friend_status_message(function(_, fid, msg, msg_len)
         assert( #msg == msg_len )
         -- Just count that as a regular message with that tag.
         tox_history:add_msg({from_id = ids[fid], msg = msg, tags={"status_message"} })
   end)

   comm:callback_friend_status(function(_, fid, status)
         -- `status` none/away/busy: suggest just using tags again.
         local list = {"none", "away", "busy"}
         tox_history:add_msg({from_id = ids[fid], msg = list[status] or "bug",
                              tags={"status_change"}})
   end)
   comm:callback_friend_connection_status(function(_, fid, status)
         print(status)  -- none/tcp/udp
   end)
   
   comm:callback_friend_typing(function(_, fid, is_typing)
   end)

   comm:callback_friend_read_receipt(function(_, fid, msg_id)
         -- Tells you it was received.(... poke gui somehow ...)
   end)

   comm:callback_friend_request(function(_, from_pubkey, msg, msg_len)
         assert( #msg == msg_len )
         -- TODO accept/deny/settings, i guess.
   end)

   comm:callback_friend_message(function(_, fid, tp, msg, msg_len)
         assert( #msg == msg_len )
         -- tp is either normal or action.
         tox_history:add_msg({from_id = ids[fid], tp = tp, msg = msg })
   end)

   comm:callback_file_recv_control(function(_, fid, file_id, control)
         -- `control` resume/pause/cancel
   end)

   comm:callback_file_chunk_request(function(_, fid, file_id, position, length)
         -- Should call the function tox_file_send_chunk with the requested chunk.
         -- (it is a request of _us_, not outward)
   end)
   comm:callback_file_recv(function(_, fid, file_id, kind,
                                        file_size, filename, filename_len)
         -- `kind` The meaning of the file to be sent
         -- `file_size` UINT64_MAX if unknown or streaming
   end)
   comm:callback_file_recv_chunk(function(_, fid, file_id, position, data, length)
   end)

   comm:callback_friend_lossy_packet(function(_, fid, data, length)
   end)
   comm:callback_friend_lossless_packet(function(_, fid, data, length)
   end)

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
