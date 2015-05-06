-- Just stripping the preceeding `tox_` at the moment.

local lib = require "raw"

local funlist = {
   "version_major",
   "version_minor",
   "version_patch",
   "version_is_compatible",
   "options_default",
   "options_new",
   "options_free",
   "bootstrap",
   "add_tcp_relay",
   "self_get_connection_status",
   "self_set_name",
   "self_get_name_size",
   "self_get_name",
   "self_set_status_message",
   "self_get_status_message_size",
   "self_get_status_message",
   "self_set_status",
   "self_get_status",
   "friend_add",
   "friend_add_norequest",
   "friend_delete",
   "friend_by_public_key",
   "friend_exists",
   "self_get_friend_list_size",
   "self_get_friend_list",
   "friend_get_public_key",
   "friend_get_last_online",
   "friend_get_name_size",
   "friend_get_name",
   "self_set_typing",
   "friend_send_message",
   "file_control",
   "file_seek",
   "file_get_file_id",
   "file_send",
   "file_send_chunk",
   "friend_send_lossy_packet",
   "friend_send_lossless_packet",
   "self_get_udp_port",
   "self_get_tcp_port",   
}

local Public = {}
for _, name in pairs(funlist) do
   Public[name] = lib["tox_" .. name]
end
return Public
