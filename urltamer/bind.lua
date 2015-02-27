--  Copyright (C) 17-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

require "urltamer.common"

local make_permissive = function(w, query)
   if not query or query == "" then query = domain_of_uri(w.view.uri) end
   print("Made permissive:", query)
   local got = responses[query] or {}
   got.impervious = true
   responses[query] = got
end
local make_normal = function(w, query)
   if not query or query == "" then query = domain_of_uri(w.view.uri) end
   local got = responses[query] or {}
   got.impervious = false
   responses[query] = got
end

local lousy = require("lousy")
local key, buf, cmd = lousy.bind.key, lousy.bind.buf, lousy.bind.cmd

add_binds("normal", {
  buf("^,k$", "Permissive urlrespond here(for session)", make_permissive),
  buf("^,K$", "urlRespond back to initial.", make_normal)
})

add_cmds({ cmd("urlPermissive", "Permissive urlrespond here(for session)",
               make_permissive) })
add_cmds({ cmd("urlDefault", "urlRespond back to initial.",
               make_normal) })
-- TODO better? Figure a 'assets domain'?
add_cmds({ cmd("urlOuterDomains", [[If needed, adds empty response,
allowing arbitrary domains.]],
               function(w) 
                  local got = shortlist[domain_of_uri(w.view.uri)] or {}
                  got.way = got.way or ""
                  shortlist[domain_of_uri(w.view.uri)] = got
               end) })
