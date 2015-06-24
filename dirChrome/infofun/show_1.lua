local c = require "o_jasper_common"

local This = c.copy_meta(require "listview.infofun.show_1")

-- TODO these two functions to common.
local string_split = require("lousy").util.string.split

local function ensure_listpath(path)
   assert(path, string.format("Cannot turn this into path, %s", path))
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

local function rel_pathname(from_dir, path)
   local flist, list = ensure_listpath(from_dir), ensure_listpath(path)
   local len, i = path_matching(flist, list)
   local ret = ""
   while i <= #flist do
      ret = ret .. "../"
      i = i + 1
   end
   ret = string.sub(ret, 1, #ret - 1) .. string.sub(path, len)
   return ret == "" and "" or ret .. "/"
end

function This.tab_repl:rel_dir()
   return rel_pathname(self.creator.path, self.e.dir)
end

function This.tab_repl:size_gist()
   return c.int_gist(self.e.size)
end
--function This.tab_repl:size_w_numcnt(sub)
--   return c.int_w_numcnt(entry.size, sub)
--end

function This.tab_repl:letter_mode ()
   return ({file="f", directory="d"})[self.e.mode] or "u"
end
function This.tab_repl:shorter_mode()
   return ({directory="dir"})[self.e.mode] or self.e.mode
end

function This:attrs()
   if not self._attrs then
      self._attrs = lfs.attributes(self.e.dir .. "/" .. self.e.file)
   end
   return self._attrs
end

function This:dates(format)
   local attrs, have = self:attrs(), {}
   for _, name in pairs{"access", "change", "modification"} do
      local same = nil
      for k,v in pairs(have) do
         if v == attrs[name] then
               same = k
         end
      end
      if same then
         have[name .. " {%_and} " .. same] = attrs[name]
         have[same] = nil
      else
            have[name] = attrs[name]
      end
   end
   local ret = ""
   for k,time in pairs(have) do
      ret = string.format(
         "%s<tr><td>%s%s:</td><td>%s</td></tr>", -- TOOD use asset fun
         ret, k,
         string.find(k, "{%_and}") and "{%_minor_same}" or "",
         os.date(format or "%c", time)
      )
   end
   return ret
end

function This.tab_repl:dates()       return self:dates() end
function This.tab_repl:slashifdir() return self.mode == "directory" and "/" or " " end
function This.tab_repl:slashifdir() return self.mode == "directory" and "/" or " " end

This.tab_repl._and = [[<span class="minor">&</span>]]

function This.tab_repl:other()
   local ret, do_which = {}, {"rdev", "ino", "blocks",
                              "nlink", "uid", "blksize", "gid", "permissions"}
   for _,k in pairs(do_which) do
      table.insert(ret, string.format("<b>%s</b>:%s", k, self:attrs()[k]))
   end
   return table.concat(ret, ", ")
end

This.tab_pat["^date_"] = function(self, _, key)
   local inside = string.match(key, "_[%w]+")
   local time = self:attrs()[string.sub(inside, 2)]
   if type(time) == "number" then
      local fmt = string.match(key, "_[%w%%]+$")
      return os.date(fmt == inside and "%c" or string.sub(fmt, 2), time)
   end
end

This.tab_pat["^dates_"] = function(self) return self:dates(string.sub(key, 7)) end

This.tab_repl.go_there_uri = {
      function(self)
         return string.format(self.e.mode == "directory" and
                                 "luakit://dirChrome/search%s/%s" or "file://%s/%s",
                              self.e.dir, self.e.file), 1
      end,

}

return c.metatable_of(This)
