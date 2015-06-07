local config = globals.dirChrome or globals.listview or {}

local c = require "o_jasper_common"

local Search = require("listview.Search")

local This = c.copy_meta(Search)

function This:config() return config end

-- TODO.. get an actual list..
function This:infofun()
   --for k,v in pairs(require "listview.infofun")  do ret[k] = v end
   --for k,v in pairs(require "dirChrome.infofun") do ret[k] = v end
   return {require "dirChrome.infofun.show_1"}
end

function This.to_js:html_of_id()
   return function(id)
      local file = self.log:file_of_id(id)
      local html = file and self:info_html_of_file(file)
      return html and #html > 0 and html  -- Makes sense.
   end
end

local function info_html(list, asset_fun, thresh)
   thresh = thresh or 0
   local html = ""
   for _, info in pairs(list) do
      if (config.priority_override or info.priority)(info) > thresh then
         html = html .. info:html(asset_fun)
      end
   end
   return html
end

function This:info_html(list, thresh)
   return info_html(list, self:asset_fun(), thresh)
end

function This:info_html_of_file(file, thresh)
   return self:info_html(self.log:info_from_file(file), thresh or -1)
end

function This:repl_list(args)
   self.log:update_whole_directory()  -- Ensure in the sql table.
   local ret = Search.repl_list(self, args)
   ret.cur_dir = self.log.path
   -- TODO better..
   ret.initial_query = "dir=" .. self.log.path
   ret.search_shown = "false"

   ret.infofuns_immediate = self:info_html(self.log:info_from_dir())
   --ret.main_file = self.log:main_file()
   return ret
end

return c.metatable_of(This)
