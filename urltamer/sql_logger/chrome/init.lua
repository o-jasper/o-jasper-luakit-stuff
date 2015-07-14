local listview = require "listview"

local domain_of_uri = require("o_jasper_common.fromtext.uri").domain_of_uri

local UriRequestsSearch = require "urltamer.sql_logger.UriRequestsSearch"

local sql_logger = require "urltamer.sql_logger"

-- Add bindings.
local cmd,buf,key = lousy.bind.cmd, lousy.bind.buf, lousy.bind.key

local function on_command(w, query)
   sql_logger.cmd_query = query or "from_domain:" .. domain_of_uri(w.view.uri)
   local v = w:new_tab("luakit://listviewURLs/search")
end

add_cmds({ cmd("listviewURLs", on_command) })

local function mk_page(meta, name)
   return meta.new{name, sql_logger, {"urltamer/sql_logger/chrome", "listview"}}
end

local pages = {
   default_name = "search",
   search      = mk_page(UriRequestsSearch, "search"),
   aboutChrome = mk_page(listview.AboutChrome, "aboutChrome"),
}

return { listviewURLs = { chrome_name = "listviewURLs", pages = pages } }
