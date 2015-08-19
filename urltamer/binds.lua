require "urltamer"
local domain_of_uri = require("o_jasper_common.fromtext.uri").domain_of_uri

local c = require "o_jasper_common"

local config = globals.urltamer or {}

if config.add_cmds == nil or config.add_cmds then
   local matchers = require "urltamer.matchers.init"
   local permissive_for_while = require "urltamer.handler.permissive_for_while"

   local function uri_to_pattern(uri)
      return "^https*://" .. string.gsub(uri, "[-]", {["-"]="[-]"}) .. ".+"
   end

   local previously = {}
   -- Makes it permissive for a while, so stuff can load. 0 time is forever.
   local function make_permissive(w, query)
      local args = c.string_split(query, " ")
      local for_time, uri = 3, nil
      if tonumber(args[1]) then
         for_time = tonumber(args[1])
         domain = domain_of_uri(args[2] or w.view.uri)
      else
         domain = domain_of_uri(args[1] or w.view.uri)
      end
      local pat = uri_to_pattern(domain)
      previously[pat] = matchers.patterns[pat]
      local function scratch() matchers.patterns[pat] = nil end
      matchers.patterns[pat] = permissive_for_while(for_time, scratch)

      print("Made permissive:", domain, uri_to_pattern(domain))
   end
   local function make_normal(w, query)
      if not query or query == "" then query = domain_of_uri(w.view.uri) end
      local pat = uri_to_pattern(query)
      matchers.patterns[pat] = previously[pat]
      print("Made normal:", query)
   end
   
   local lousy = require("lousy")
   local key, buf, cmd = lousy.bind.key, lousy.bind.buf, lousy.bind.cmd
   
   add_cmds({ cmd("urlPermissive", "Permissive urlrespond here(for session)",
                  make_permissive) })
   add_cmds({ cmd("urlNormal", "urlRespond back to initial.",
                  make_normal) })
end
