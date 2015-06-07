local c = require "o_jasper_common"

local This = c.copy_meta(require "listview.infofun.show_1")

function This.maybe_new(creator, entry) 
   return setmetatable({ from_path = creator.path, e=entry }, This)
end

-- TODO these two functions to common.
local string_split = require("lousy").util.string.split

local function ensure_listpath(path)
   assert(path, "Cannot turn this into path %s", path)
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
   return rel_pathname(self.e.from_dir, self.dir)
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
This.tab_repl.go_there_uri = {
      function(self)
         return string.format(self.e.mode == "directory" and
                                 "luakit://dirChrome/search%s/%s" or "file://%s/%s",
                              self.e.dir, self.e.file), 1
      end,
}

return c.metatable_of(This)
