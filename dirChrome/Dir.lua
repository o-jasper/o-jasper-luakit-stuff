
local config = globals.dirChrome or globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

local c = require "o_jasper_common"
local string_split = require("lousy").util.string.split

local SqlHelp = require("sql_help").SqlHelp
local cur_time = require "o_jasper_common.cur_time"

local DirEntry = require "dirChrome.DirEntry"

local This = c.copy_meta(SqlHelp)

This.values = DirEntry.values
function This:config() return config end

This.cmd_dict.select_dir =
   "SELECT * FROM {%table_name} WHERE dir == ?"
This.cmd_dict.select_path =
   "SELECT id FROM {%table_name} WHERE dir == ? AND file == ?"
This.cmd_dict.delete_path =
   "DELETE FROM {%table_name} WHERE dir == ? AND file == ?"

--This.cmd_dict.file_of_id = "SELECT file FROM files WHERE id == ?"
--function This:file_of_id(id)
--   local got = self:sqlcmd("file_of_id"):exec({id})[1]
--   if got then return got.file end
--end

This.entry_meta = DirEntry

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
   if entry then
      self:update_or_enter(entry)
      return This:entry_fun(entry)
   end
end

local infofun_lib = require "sql_help.infofun"

function This:update_whole_directory()
   self.info_from_dir_list = {}
   for file, _ in lfs.dir(self.path) do
      local entry = self:update_file(file)
      if entry then
         local list = infofun_lib.entry_thresh_priority(self, entry, self:dir_infofun(), 0)
         infofun_lib.priority_sort(list, self:config().priority_override)
         for _, el in pairs(list) do
            table.insert(self.info_from_dir_list, el)
         end
      end
   end
end

function This:info_from_dir()
   return self.info_from_dir_list
end

function This:dir_infofun()
   return config.dir_infofun or {
      require "dirChrome.infofun.markdown", require "dirChrome.infofun.basic_img", 
      require "dirChrome.infofun.file"}
end

-- Scratch some search matchabled that arent allowed.
This.searchinfo.matchable = {
   "like:", "-like:", "-", "not:", "\\-", "or:",
   "sizelt:", "sizegt:",
   "before:", "after:",
   "access_before:", "access_after:",
   "limit:",
   "order:", "sort:", "orderby:",
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

-- Adds collumn-specific searches.
for _, el in pairs{"mode", "dir", "file"} do
   for _, kind in pairs{"=", "like:", ":"} do
      mod_match_funs[el .. kind] = This.searchinfo.match_funs["uri" .. kind]
      table.insert(This.searchinfo.matchable, el .. kind)
   end
end

for k, v in pairs(mod_match_funs) do This.searchinfo.match_funs[k] = v end

function This:config() return config end

function This:update_or_enter(entry)
   -- Delete pre-existing.
   self:sqlcmd("delete_path"):exec({entry.dir, entry.file})
   assert(not entry.id) -- Re enter.,
      return SqlHelp.update_or_enter(self, entry)
end

return c.metatable_of(This)
