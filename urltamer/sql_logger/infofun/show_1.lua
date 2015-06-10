local c = require "o_jasper_common"

local This = c.copy_meta(require "listview.infofun.show_1")

function This.maybe_new(_, entry) return setmetatable({ e=entry }, This) end

function This.tab_repl:resultHTML()
   return ({["true"]="{%urlallowed}", ["false"]="{%urlblocked}"})[self.e.result] or
      [[<span class="redirect_ann">redirected:</span>
<span class="redirect">{%result}</span]]
end

This.tab_repl.urlallowed = [[<span class="allowed">allowed</span>]]
This.tab_repl.urlblocked = [[<span class="allowed">blocked</span>]]

local fancy_uri = c.html.fancy_uri
function This.tab_repl:vuriHTML() return fancy_uri(self.e.vuri) end
function This.tab_repl:uriHTML()  return fancy_uri(self.e.uri) end
function This.tab_repl:vuri_len() return #(self.e.vuri or {}) end
function This.tab_repl:uri_len()  return #self.e.uri end

return c.metatable_of(This)
