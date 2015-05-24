require "urltamer"
local domain_of_uri = require("o_jasper_common.fromtext.uri").domain_of_uri

local config = globals.urltamer or {}

if config.add_cmds == nil or config.add_cmds then
   local function uri_to_pattern(uri)
      return "^" .. string.gsub(uri, "[-]", {["-"]="[-]"}) .. "$"
   end

   local function make_permissive(w, query)
      if not query or query == "" then query = domain_of_uri(w.view.uri) end
      pattern_shortlist[uri_to_pattern(query)] = permissive
      print("Made permissive:", query)
   end
   local function make_normal(w, query)
      if not query or query == "" then query = domain_of_uri(w.view.uri) end
      pattern_shortlist[uri_to_pattern(query)] = nil
      print("Made normal:", query)
   end
   
   local lousy = require("lousy")
   local key, buf, cmd = lousy.bind.key, lousy.bind.buf, lousy.bind.cmd
   
   add_cmds({ cmd("urlPermissive", "Permissive urlrespond here(for session)",
               make_permissive) })
   add_cmds({ cmd("urlNormal", "urlRespond back to initial.",
                  make_normal) })
end
