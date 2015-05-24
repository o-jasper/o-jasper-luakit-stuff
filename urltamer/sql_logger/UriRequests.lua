
local config = (globals.urltamer or {}).uri_requests or globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

local c = require "o_jasper_common"
local UriRequestsEntry = require "urltamer.sql_logger.UriRequestsEntry"

local UriRequests = c.copy_meta(require("sql_help").SqlHelp)
UriRequests.values = UriRequestsEntry.values

-- Scratch some search matchabled that arent allowed.
UriRequests.searchinfo.matchable = {
   "like:", "-like:", "-", "not:", "\\-", "or:",
   "uri:", "urilike:",
   "before:", "after:", "limit:",
   -- TODO these currently do nothing/bug-out, add to `searchinfo.match_funs`
   "domain:", "from_domain:",
}

function UriRequests:config() return config end
function UriRequests:initial_state() return {} end

UriRequests.entry_meta = UriRequestsEntry

local cur_time = require "o_jasper_common.cur_time"

local last_id = 0

function UriRequests.insert(self, info, result)
   info.id = 1000*cur_time.ms()
   while info.id <= last_id do
      info.id = info.id + 1
   end
   last_id = info.id
   info.result = tostring(result.ret)   -- Just add what isnt in there yet.
   info.time = cur_time.ms()

   self:enter(info)
end

return c.metatable_of(UriRequests)
