-- Just stripping the preceeding `tox_` at the moment.

local raw = require "ffi.tox.raw"

local plain_funlist = {
   "version_major",
   "version_minor",
   "version_patch",
   "version_is_compatible",
   "options_new",
   "new",
}

local opts_funlist = {
   options_default = false,
   options_free = false,   
}

local tox_funlist = {
   bootstrap = false,
   self_get_name_size = false,
   self_get_name = {},
   self_set_name = {},
   self_get_connection_status = false,
   self_set_status_message = {},
   self_get_status_message_size = false,
   self_get_status_message = {},
   self_set_status = false,
   self_get_status = false,
   self_get_public_key = {},
   self_get_address = {},
   self_get_secret_key = {},

   get_savedata = {},

   friend_add = false,
   friend_add_norequest = false,
   friend_delete = false,
   friend_by_public_key = false,
   friend_exists = false,
   self_get_friend_list_size = false,
   self_get_friend_list = false,
   friend_get_public_key = false,
   friend_get_last_online = false,
   friend_get_name_size = false,
   friend_get_name = {},
   self_set_typing = false,
   friend_send_message = false,
   add_tcp_relay = false,
   friend_send_lossy_packet = false,
   friend_send_lossless_packet = false,
   file_control = false,
   file_seek = false,
   file_get_file_id = false,
   file_send = false,
   file_send_chunk = false,
   self_get_udp_port = false,
   self_get_tcp_port = false,
}

local Public = { raw=raw, Tox={}, Opts={} }

for _, name in pairs(plain_funlist) do
   Public[name] = raw["tox_" .. name]
end
for k, info in pairs(opts_funlist) do
   local fun = raw["tox_" .. k]
   local name = (not info and k) or info.name or "_" .. k
   Public.Opts[name] = function(self, ...) return fun(self.cdata, ...) end
end
for k, info in pairs(tox_funlist) do
   local fun = raw["tox_" .. k]
   local name = (not info and k) or info.name or "_" .. k
   Public.Tox[name] = function(self, ...) return fun(self.cdata, ...) end
end

local ffi = require "ffi"

local function ret_via_arg(name, ctp, rawname, szname)
   local rawname = rawname or "_" .. name
   local szname  = szname  or name .. "_size"
   local ctp = tp or "char[?]"
   return function(self)
      local sz = self[szname](self)
      local ret = ffi.new(ctp, sz)
      self[rawname](self, ret)
      return ffi.string(ret, sz)
   end
end

local function Tox_ret_via_arg(name, ...) Public.Tox[name] = ret_via_arg(name, ...) end

Tox_ret_via_arg("self_get_name")
Tox_ret_via_arg("self_get_status_message")

Tox_ret_via_arg("self_get_friend_list", "uint32_t[?]")

Tox_ret_via_arg("get_savedata", "uint8_t[?]")

local function Tox_ret_via_arg_no_size(name, ctp, rawname)
   local rawname = rawname or "_" .. name
   local ctp = tp or "uint8_t[32]"
   Public.Tox[name] = function(self)
      local ret = ffi.new(ctp)
      self[rawname](self, ret)
      return ret
   end
end
Tox_ret_via_arg_no_size("self_get_public_key")
Tox_ret_via_arg_no_size("self_get_secret_key"
)Tox_ret_via_arg_no_size("self_get_address")

Public.Tox.__index  = Public.Tox
Public.Opts.__index = Public.Opts

function Tox_set_default_size(name, ...)
   local rawname = "_" .. name
   Public.Tox[name] = function(self, to, size, err) 
      return self[rawname](self, to, size or #to, err)
   end
end

Tox_set_default_size("self_set_name")
Tox_set_default_size("self_status_message")

function Public.options_new(err)
   return setmetatable({ cdata = raw.tox_options_new(err) }, Public.Opts), err
end
Public.Opts.new = Public.options_new

function Public.new(opts, data, len, err)
   if type(opts) == "table" then assert(opts.cdata) opts = opts.cdata end
   return setmetatable({ cdata = raw.tox_new(opts, data, len or 0, err) }, Public.Tox)
end

Public.Tox.new = Public.new

return Public
