--  Copyright (C) 25-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- TODO make it a proper package..

local domain_status = require "urltamer.domain_status"

local ensure = require "o_jasper_common.ensure"
local domain_of_uri = require("o_jasper_common.fromtext.uri").domain_of_uri

local cur_time = require "o_jasper_common.cur_time"

local config = globals.urltamer or {}

local new_info  = require("urltamer.info").new_info

config.late_dt = config.late_dt or 4000
config.log_all = (config.log_all == nil) or config.log_all
config.logger = require "urltamer.sql_logger"

handler = {}

function handler.base(info, result, also_allow)
   if info.uri == "about:blank" or info.by_userevent then
      result.allow = true
   elseif info.dt > config.late_dt or
        info:uri_match({"^.+[.][fF][lL][vV]$", "^.+[.][sS][wW][fF]$"}) then
      result.was_late = true
      result.allow = false
   elseif also_allow and info:uri_match(also_allow) then  -- (Doesnt excuse tardiness)
      result.specific_allow = true
      result.allow = true
   else
      result.allow = true
   end
end

function handler.everywhere(info, result, also_allow)
   handler.base(info, result, also_allow)
   if not info:own_domain() and not (info.by_userevent or result.specific_allow) then
      result.allow = false
   end
end

-- If not shortlisted, keep it on own domain,
not_listed = handler.everywhere
shortlist = {}
pattern_shortlist = {}

function respond_to(info, result)
   local domain_way = nil
   for k,v in pairs(pattern_shortlist) do
      if string.match(info.vuri or info.uri, k) then domain_way = v end
   end
   if not domain_way then
      domain_way = shortlist[info.from_domain] or not_listed
   end
   -- TODO sql table. (possibly via metatable)
   if type(domain_way) == "string" then
      -- TODO use the environment argument.
      load("return " .. domain_way, nil, "t")(info, result)
   else
      domain_way(info, result)
   end
end

local uri_cnt, cur_allowed = 0, {}
config.allowed_t = config.allowed_t or 100

local function _domain_of_uri(uri)
   return type(uri) == "string" and domain_of_uri(uri) or "none"
end

function userevent_uri(uri, vuri)
   domain_status.now(_domain_of_uri(uri), "userevent-uri")
   cur_allowed[uri] = {cur_time.ms(), 2, vuri or uri}
end

window.init_funcs.inspector_setup = function (w)
   w.tabs:add_signal("switch-page", function (_, view, reason) 
       if uri then userevent_uri(view.uri) end
   end)
end

webview.init_funcs.url_respond_signals = function (view, w)
   -- This does not look necessary anymore, navigation-request is the signal i am looking for.
   -- view:add_signal("userevent-uri", function (v, uri) userevent_uri(uri, v.uri) end)

   view:add_signal("navigation-request", function (v, uri) userevent_uri(uri, v.uri) end)

   view:add_signal("resource-request-starting", function (v, uri)
          uri_cnt = uri_cnt + 1

          -- Get info on domain.
          local info  = new_info(v, uri)

          -- User events can poke a hole, if it listens to `by_userevent`
          local allowed = cur_allowed[info.uri]
          if allowed then
             allowed[2] = allowed[2] - 1
             if config.allowed_t > allowed[1] - info.time and allowed[2] > 0 and
                (v.uri == nil or v.uri == allowed[3]) then
                info.by_userevent = allowed
             end
             cur_allowed[info.uri] = nil
          end

          local result = { remarks = {} }
          respond_to(info, result)
         
          if not result.allow or result.disallow then
             result.ret = false
          elseif result.redirect then
             result.ret = result.redirect
          else
             result.ret = true
          end

          if (result.log or config.log_all) and config.logger then
             config.logger:insert(info, result)
          end
          
          return result.ret
   end)
   view:add_signal("load-status",
       function (v, status)
          local info = new_info(v, nil)
          domain_status.now(_domain_of_uri(uri), status)
       end)
end
