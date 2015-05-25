
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
   "domain:", "from_domain:", "domainlike:", "from_domainlike:",
   "result:", "resultlike"
}

local function dom_match_fun(sub_n, wrap) return function (self, state, m, v)
   self:like(string.sub(m, 1, #m - sub_n), wrap .. v .. wrap, state.n)
end end

local dom_search = dom_match_fun(1, "%")
UriRequests.searchinfo.match_funs["domain:"] = dom_search
UriRequests.searchinfo.match_funs["from_domain:"] = dom_search
UriRequests.searchinfo.match_funs["result:"] = dom_search

local dom_like = dom_match_fun(5, "")
UriRequests.searchinfo.match_funs["domainlike:"] = dom_like
UriRequests.searchinfo.match_funs["from_domainlike:"] = dom_like
UriRequests.searchinfo.match_funs["resultlike:"] = dom_like

function UriRequests:config() return config end
function UriRequests:initial_state() return {} end

UriRequests.entry_meta = UriRequestsEntry

local cur_time = require "o_jasper_common.cur_time"

UriRequests.last_id = 1000*cur_time.ms()

function UriRequests.insert(self, info, result)
   info.id = 1000*cur_time.ms()
   while info.id <= self.last_id do
      info.id = info.id + 1
   end
   self.last_id = info.id
   info.result = tostring(result.ret)   -- Just add what isnt in there yet.
   info.time = cur_time.ms()

   self:enter(info)
end

function UriRequests.config(self) return config end

local entry_html = require "listview.entry_html"

local fancy_uri = require("o_jasper_common.html.uri").fancy_uri

function UriRequests.initial_state(self)
   local mod_html_calc = {
      resultHTML = function(entry, _)
         return ({["true"]="{%urlallowed}", ["false"]="{%urlblocked}"})[entry.result] or
            [[<span class="redirect_ann">redirected:</span>
<span class="redirect">{%result}</span]]
      end,
      -- Might be a tad confusing..
      urlallowed = function(...) return [[<span class="allowed">allowed</span>]] end,
      urlblocked = function(...) return [[<span class="blocked">blocked</span>]] end,

      vuriHTML = function(entry, _) return fancy_uri(entry.vuri) end,
      uriHTML = function(entry, _) return fancy_uri(entry.uri) end,

      vuri_len = function(entry, _) return #(entry.vuri or {}) end,
      uri_len = function(entry, _)  return #entry.uri end,
   }
   local html_calc = c.copy_table(entry_html.default_html_calc)
   for k,v in pairs(mod_html_calc) do html_calc[k] = v end
   return { html_calc=html_calc }
end

return c.metatable_of(UriRequests)
