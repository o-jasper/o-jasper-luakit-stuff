require "urltamer.common"

local listview = require "listview"
local sql_logger = require "urltamer.sql_logger"

local paged_chrome = require("paged_chrome")

local config = (globals.urltamer or {}).sql_logger or {}

local function chrome_describe(log)
   assert(log)
   
   local where = config.assets or {}
   table.insert(where, "listview")
   table.insert(where, "urltamer/sql_logger/chrome")
   local pages = listview.new_Chrome(log, where)

   config.page = config.page or {}
   pages.search.limit_cnt = config.page.cnt or 20
   pages.search.limit_step = config.page.step or pages.search.step_cnt
   return pages
end

paged_chrome.paged_chrome("listviewURLs", chrome_describe(sql_logger))

-- Add bindings.
local cmd,buf,key = lousy.bind.cmd, lousy.bind.buf, lousy.bind.key

local function on_command(w, query)
   history.cmd_query = query or "from_domain:" .. domain_of_uri(w.view.uri)
   local v = w:new_tab("luakit://listviewURLs/search")
end

add_cmds({ cmd("listviewURLs", on_command) })
