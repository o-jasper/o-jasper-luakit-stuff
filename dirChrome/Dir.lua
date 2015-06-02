
local config = globals.listview_dir or globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

local c = require "o_jasper_common"
local SqlHelp = require("sql_help").SqlHelp
local cur_time = require "o_jasper_common.cur_time"

local DirEntry = require "dirChrome.DirEntry"

local this = c.copy_meta(SqlHelp)

this.values = DirEntry.values

-- Scratch some search matchabled that arent allowed.
this.searchinfo.matchable = {
   "like:", "-like:", "-", "not:", "\\-", "or:",
   "mode:", "dir:", "file:", "dirlike:", "filelike:",
   "sizelt:", "sizegt:",
   "before:", "after:",
    "access_before:", "access_after:",
    "limit:"
}  -- TODO need the functions.

this.entry_meta = DirEntry
  
function this:config() return config end
function this:initial_state() return {} end

function this:update_or_enter(entry)
   -- Delete pre-existing.
   self:sqlcmd("delete_path"):exec({entry.dirname, entry.filename})
   assert(not entry.id) -- Re enter.,
      return SqlHelp.update_or_enter(self, entry)
end

this.cmd_dict.select_path =
   "SELECT id FROM {%table_name} WHERE dirname == ? AND filename == ?"
this.cmd_dict.delete_path =
   "DELETE FROM {%table_name} WHERE dirname == ? AND filename == ?"

-- TODO these two functions to common.
local string_split = require("lousy").util.string.split

local function ensure_listpath(path)
   assert(path, "Cannot turn this into path")
   return (type(path) == "string" and string_split(path, "/")) or path
end

-- Matching part of paths.
local function path_matching(match_path, path)
   local len, mlist, list = 0, ensure_listpath(match_path), ensure_listpath(path)
   for i,mstr in pairs(mlist) do
      if list[i] ~= mstr then
         return len, i
      end
      len = len + #mstr + 1
   end
   --assert( len == #match_path and len == #path,
   --string.format("%s ~= %d or ~= %d", len, #match_path, #path))
   return len, #mlist
end

local function rel_pathname(from_path, path)
   local flist, list = ensure_listpath(from_path), ensure_listpath(path)
   local len, i = path_matching(flist, list)
   local ret = ""
   while i < #flist do
      ret = ret .. "../"
      i = i + 1
   end
   return ret .. string.sub(path, len + 1)
end

local entry_html = require("listview.entry_html")

function this:initial_state()
   local mod_html_calc = {
      rel_dirname = function(entry)
         return rel_pathname(self.path, entry.dirname)
      end,
   }
   local html_calc = c.copy_table(entry_html.default_html_calc)
   for k,v in pairs(mod_html_calc) do html_calc[k] = v end
   return { html_calc=html_calc }
end

return c.metatable_of(this)
