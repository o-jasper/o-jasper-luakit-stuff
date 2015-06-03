
local config = globals.dirChrome or globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

local c = require "o_jasper_common"
local string_split = require("lousy").util.string.split

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

local cur_match_funs = this.searchinfo.match_funs

local mod_match_funs = {
   ["mode:"] = function(self, _, m, v)  -- Exact mode(s)
      self:equal_one_or_list("mode", string_split(v))
   end,
   ["sizelt:"] = function(self, _, m, v)  -- TODO .. units and stuff.
      self:lt("size", c.fromtext.w_magnitude_interpret(v))
   end,
   ["sizegt:"] = function(self, _, m, v)
      self:gt("size", c.fromtext.w_magnitude_interpret(v))
   end,
   ["access_before:"] = function(self, _, m, v)
      self:lt("size", c.fromtext.time_interpret(v))
   end,
   ["access_after:"] = function(self, _, m, v)
      self:gt("size", c.fromtext.time_interpret(v))
   end,
   ["dir:"] = cur_match_funs["uri:"],
   ["dirlike:"] = cur_match_funs["urilike:"],
   ["file:"] = cur_match_funs["uri:"],
   ["filelike:"] = cur_match_funs["urilike:"],
}

for k, v in pairs(mod_match_funs) do this.searchinfo.match_funs[k] = v end

this.entry_meta = DirEntry
  
function this:config() return config end
function this:initial_state() return {} end

function this:update_or_enter(entry)
   -- Delete pre-existing.
   self:sqlcmd("delete_path"):exec({entry.dir, entry.file})
   assert(not entry.id) -- Re enter.,
      return SqlHelp.update_or_enter(self, entry)
end

this.cmd_dict.select_path =
   "SELECT id FROM {%table_name} WHERE dir == ? AND file == ?"
this.cmd_dict.delete_path =
   "DELETE FROM {%table_name} WHERE dir == ? AND file == ?"

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
   return len, #mlist + 1
end

local function rel_pathname(from_path, path)
   local flist, list = ensure_listpath(from_path), ensure_listpath(path)
   local len, i = path_matching(flist, list)
   local ret = ""
   while i <= #flist do
      ret = ret .. "../"
      i = i + 1
   end
   ret = string.sub(ret, 1, #ret - 1) .. string.sub(path, len)
   return ret == "" and "" or ret .. "/"
end

local entry_html = require("listview.entry_html")

function this:initial_state()
   local mod_html_calc = {
      rel_dir = function(entry)
         return rel_pathname(self.path, entry.dir)
      end,
      size_gist = function(entry)
         return c.int_gist(entry.size)
      end,
      size_w_numcnt = function(entry, sub)
         return c.int_w_numcnt(entry.size, sub)
      end,
      letter_mode  = function(entry)
         return ({file="f", directory="d"})[entry.mode] or "u"
      end,
      shorter_mode = function(entry)
         return ({directory="dir"})[entry.mode] or mode
      end,
   }
   local html_calc = c.copy_table(entry_html.default_html_calc)
   for k,v in pairs(mod_html_calc) do html_calc[k] = v end

   local priority_funs = {
      go_there_uri = {
         function(entry)
            return string.format(entry.mode == "directory" and
                                    "search%s/%s" or "file://%s/%s",
                                 entry.dir, entry.file), 1
         end,
      },
   }

   for k,v in pairs(config.priority_funs or {}) do
      if priority_funs[k] then
         table.insert(priority_funs[k], v)
      else
         priority_funs[k] = {v}
      end
   end

   return { html_calc= html_calc, config = { priority_funs = priority_funs } }
end

function this:incorporate_info(entry)
   -- TODO
end

return c.metatable_of(this)
