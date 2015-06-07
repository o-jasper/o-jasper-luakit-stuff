
local config = globals.dirChrome or globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

config.infofuns = config.infofuns or {"markdown", "basic_img", "file"}

local c = require "o_jasper_common"
local string_split = require("lousy").util.string.split

local SqlHelp = require("sql_help").SqlHelp
local cur_time = require "o_jasper_common.cur_time"

local DirEntry = require "dirChrome.DirEntry"

local This = c.copy_meta(SqlHelp)

This.values = DirEntry.values
function This:config() return config end

This.cmd_dict.file_of_id = "SELECT file FROM files WHERE id == ?"
function This:file_of_id(id)
   local got = self:sqlcmd("file_of_id"):exec({id})[1]
   if got then return got.file end
end

local function entry_from_file(path, file)
   local entry =  lfs.attributes(path .. "/" .. file)
   if not ( {["."]=true, [".."]=true})[file] and entry then
      entry.dir = path
      entry.file = file
      entry.time_access = entry.access
      entry.time_modified = entry.modification
      return entry
   end
end

function This:entry_from_file(file, path) 
   local entry = entry_from_file(path or self.path, file) 
   if entry then
      for n,_ in pairs(getmetatable(self).values.string_els) do  -- Checking a bunch.
         assert( type(entry[n]) == "string",
              string.format("%s not string, but %s", n, entry[n]))
      end
      for n,_ in pairs(getmetatable(self).values.int_els) do
         assert( type(entry[n]) == "number" or n == "id",
                 string.format("%s not integer, but %s", n, entry[n]))
      end
      return entry
   end
end
function This:update_file(file)
   local entry = self:entry_from_file(file)
   return entry and self:update_or_enter(entry)
end
function This:update_whole_directory()
   for file, _ in lfs.dir(self.path) do self:update_file(file) end
end

-- TODO factor out the info list part?
local infofuns_funs = require "dirChrome.infofun"

local function default_compare(a, b)
   return (config.priority_override or a.priority)(a) > 
      (config.priority_override or b.priority)(b)
end

function This:info_priority_sort(list)
   if not self:config().dont_sort then
      table.sort(list, self:config().priority_compare or default_compare)
   end
   return list
end

function This:info_from_file(file, into_list, dont_sort, infofuns)
   into_list = into_list or {}
   for key, fun in pairs(infofuns or self:config().infofuns) do
      if fun == true then fun = key end
      if type(fun) == "string" then fun = infofuns_funs[fun] end
      local info = fun.maybe_new(self.path, file)
      if info then table.insert(into_list, info) end
   end
   if not dont_sort then self:info_priority_sort(into_list) end
   return into_list
end

function This:info_from_dir(into_list, dont_sort)
   into_list = into_list or {}
   for file in lfs.dir(self.path) do
      self:info_from_file(file, into_list, true, self:config().infofuns)
   end
   if not dont_sort then self:info_priority_sort(into_list) end
   return into_list
end

-- Scratch some search matchabled that arent allowed.
This.searchinfo.matchable = {
   "like:", "-like:", "-", "not:", "\\-", "or:",
   "sizelt:", "sizegt:",
   "before:", "after:",
   "access_before:", "access_after:",
   "limit:"
}  -- TODO need the functions.

local mod_match_funs = {
   ["sizelt:"] = function(self, _, m, v)  -- TODO .. units and stuff.
      self:lt("size", c.fromtext.w_magnitude_interpret(v))
   end,
   ["sizegt:"] = function(self, _, m, v)
      self:gt("size", c.fromtext.w_magnitude_interpret(v))
   end,
   ["access_before:"] = function(self, _, m, v)
      local t = c.fromtext.time_interpret(v)
      if t then self:lt("access", t) end
   end,
   ["access_after:"] = function(self, _, m, v)
      local t = c.fromtext.time_interpret(v)
      if t then self:gt("access", t) end
   end,
}

for _, el in pairs{"mode", "dir", "file"} do
   for _, kind in pairs{"=", "like:", ":"} do
      mod_match_funs[el .. kind] = This.searchinfo.match_funs["uri" .. kind]
      table.insert(This.searchinfo.matchable, el .. kind)
   end
end

for k, v in pairs(mod_match_funs) do This.searchinfo.match_funs[k] = v end

This.entry_meta = DirEntry
  
function This:config() return config end

function This:update_or_enter(entry)
   -- Delete pre-existing.
   self:sqlcmd("delete_path"):exec({entry.dir, entry.file})
   assert(not entry.id) -- Re enter.,
      return SqlHelp.update_or_enter(self, entry)
end

This.cmd_dict.select_path =
   "SELECT id FROM {%table_name} WHERE dir == ? AND file == ?"
This.cmd_dict.delete_path =
   "DELETE FROM {%table_name} WHERE dir == ? AND file == ?"

return c.metatable_of(This)
