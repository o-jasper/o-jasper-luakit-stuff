--  Copyright (C) 25-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

require "urltamer.common"
require "urltamer.domain_status"

-- Values directly returned, for instance member functions.
local info_metaindex_direct = {}
-- Values that are determined and memoized. (though memoizing is not necessarily better)
local info_metaindex_determine = {
   tags = function(self, _) return "" end,
   domain = function(self, _) return domain_of_uri(self.uri or "no_uri") end,
   
   vuri = function(self, _) return self.v.uri end,
   from_domain = function(self, _) return domain_of_uri(self.vuri or "no_vuri") end,

   current_status = function(self, _)
      local got = _domain_status[self.from_domain]
      if not got then
         got = {}
         assert(self.from_domain, string.format("aint got (%s)", self.from_domain))
         _domain_status[self.from_domain] = got
      end
      return got
   end,
   status = function(self, _) return self.current_status.status end,

   -- TODO destructive.. probably dont want.
   from_time = function(self, _) 
      return (self.current_status.times or {})["userevent-uri"] or 0
   end, 
   dt = function(self, _) return self.time - self.from_time end,
}

local info_metatable = {__index=function(self, key)
   local got = rawget(self, key) or info_metaindex_direct[key]
  -- Return value, because set, or because specified by metatable.c
   if got or type(got) == "boolean" then
      return got(self, key)
   else
      local determiner = info_metaindex_determine[key]
      if determiner then  -- To be determined by functions.
         local val = determiner(self, key)
         rawset(self,key, val)
         return val
      end
      return nil
   end
end,
   -- TODO setting indexes?
}

function new_info(v, uri)
   local info = {v=v, uri=uri, time=gettime()}
   setmetatable(info, info_metatable)
   return info
end

everywhere = [[:hard=true
:about_blank_redirect vuri yes
:allow_userevent
:hard=false
:block_late 1000
:set_result weakyes true
:hardno=true
:fun=disallow
^.+[.][fF][lL][vV]$
^.+[.][sS][wW][fF]$
:hardno=false]]

-- If not shortlisted, keep it on own domain,
no_shortlist = [[:own_domain]]

shortlist = {}

function respond_to(info, result)
   local domain_way = (shortlist[info.from_domain]or {}).way or no_shortlist
   return parametered_matches(everywhere .. "\n" .. domain_way,
                              info.uri, info, result,
                              urlcommands, urlfuncs)
end

responses = {}
log = {}
uri_cnt = 0

stats = {}
function keep_stats(info, result, prep, status, prnt)
   if prnt then print(info.uri, info.vuri, result.line) end
   for _, el in pairs(result.remarks) do
      stats[prep .. el] = (stats[prep .. el] or 0) + 1
      if prnt then
         print(string.format("%s%s:%s %d", prep, status, el, stats[prep .. el]))
         if el == "block_late" then
            print(info.dt)
         end
      end
      info.finally = string.sub(prep, 1, #prep - 1)
      local dt= info.dt
   end
end

cur_allowed = {}
allowed_t = 100

function userevent_uri(uri, vuri)
   status_now(_domain_of_uri(uri), "userevent-uri")
   cur_allowed[uri] = {socket.gettime()*1000, 2, vuri or uri}
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

          if (uri and string.match(uri, "^luakit://.+")) or
             (v.uri and string.match(v.uri, "^luakit://.+")) then
             print("luakit")
             return
          end
          -- Get info on domain.
          local info  = new_info(v, uri)

          local responder = responses[info.from_domain] or {}
          if responder.impervious then
             if not allow then print("Imperviousness", info.uri) end
             return true
          end

          -- User events can poke a hole. (TODO.. ensure they're actually user events?)
          -- TODO just stuff it in the info.
          local allowed = cur_allowed[info.uri]
          if allowed then
             allowed[2] = allowed[2] - 1
             if allowed_t > allowed[1] - info.time and allowed[2] > 0 and
                (v.uri == nil or v.uri == allowed[3]) then
                info.by_userevent = allowed
             end
             cur_allowed[info.uri] = nil
          end

          local allow, result = 
             (responder.resource_request_starting or respond_to)(info, new_result())

          if result.log then table.insert(log, {info, result}) end
          
          if not allow then
             keep_stats(info, result or {}, "block:", info.status, true)
             return false
          elseif result.redirect then
             keep_stats(info, result or {}, "redirect:", info.status)
             return result.redirect
          else
             keep_stats(info, result or {}, "allow:", info.status)
             return true
          end
   end)
   view:add_signal("load-status",
       function (v, status)
          local info = new_info(v, nil)
          status_now(_domain_of_uri(uri), status)

          local responder = responses[info.from_domain] or {}          
          if responder and responder.load_status then
             return responder.load_status(info)
          end
       end)

--   view:add_signal("button-press", function (v, mods, button, context)
--           if button == 1 and v.hovered_uri then
--              v:emit_signal("userevent-uri", v.hovered_uri)
--           end
--       end)
end
