
local config = (globals.urltamer or {}).uri_requests or globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

local c = require "o_jasper_common"
local UriRequestsEntry = require "urltamer.sql_logger.UriRequestsEntry"

local this = c.copy_meta(require("sql_help").SqlHelp)
this.values = UriRequestsEntry.values

-- Scratch some search matchabled that arent allowed.
this.searchinfo.matchable = {
   "like:", "-like:", "-", "not:", "\\-", "or:",
   "before:", "after:", "limit:",
}

for _, el in pairs{"uri", "domain", "from_domain", "result"} do
   for _, kind in pairs{"=", "like:", ":"} do
      this.searchinfo.match_funs[el .. kind] = this.searchinfo.match_funs["uri" .. kind]
      table.insert(this.searchinfo.matchable, el .. kind)
   end
end

this.entry_meta = UriRequestsEntry

local cur_time = require "o_jasper_common.cur_time"

this.last_id = 1000*cur_time.ms()

function this:insert(info, result)
   info.id = 1000*cur_time.ms()
   while info.id <= self.last_id do
      info.id = info.id + 1
   end
   self.last_id = info.id
   info.result = tostring(result.ret)   -- Just add what isnt in there yet.
   info.time = cur_time.ms()

   self:enter(info)
end

function this:config() return config end

local fancy_uri = require("o_jasper_common.html.uri").fancy_uri

-- TODO replace with new approach..
function this:initial_state()
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

return c.metatable_of(this)
