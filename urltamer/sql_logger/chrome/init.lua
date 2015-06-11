local listview = require "listview"
local sql_logger = require "urltamer.sql_logger"

local paged_chrome = require("paged_chrome")

local domain_of_uri = require("o_jasper_common.fromtext.uri").domain_of_uri

local UriRequestsSearch = require "urltamer.sql_logger.UriRequestsSearch"

local function chrome_describe(log)
   assert(log)
   
   local where = {"urltamer/sql_logger/chrome", "listview"}
   return {
      default_name = "search",
      search      = paged_chrome.templated_page(UriRequestsSearch.new{log, where}, "search"),
      aboutChrome = paged_chrome.templated_page(listview.AboutChrome.new{log, where},
                                                "aboutChrome"),
   }
end

paged_chrome.paged_chrome("listviewURLs", chrome_describe(sql_logger))

-- Add bindings.
local cmd,buf,key = lousy.bind.cmd, lousy.bind.buf, lousy.bind.key

local function on_command(w, query)
   sql_logger.cmd_query = query or "from_domain:" .. domain_of_uri(w.view.uri)
   local v = w:new_tab("luakit://listviewURLs/search")
end

add_cmds({ cmd("listviewURLs", on_command) })
