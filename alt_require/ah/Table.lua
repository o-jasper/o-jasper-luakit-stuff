-- Messy: not sure of direction at this point.
-- Figuring trying restrictive.

local ar = require "alt_require"
local c  = require "o_jasper_common.meta"

local SimpleBase = require "alt_require.ah.SimpleBase"
local This = c.copy_meta(SimpleBase)
This.__name = "alt_require.ah.Table"

This.new_remap = { "env" }

This.new_defaults = { 
   env = SimpleBase.new_defaults.env,
   cnts = {},
   vals = {}, 
   cnts_require = {}
}

--This.allow_global = false
This.record_require_file = true
This.record_any = true
This.recurse = true

function This:record_require(str)
   self.cnts_require[str] = (self.cnts_require[str] or 0) + 1
end

function This:init()
   if self.recurse then
      self.env = self.env or {}
      self.env.require = ar.alt_require(self)
   end
   if self.record_require_file then
      -- Otherwise it will just access the existing one.
      local oldrequire = self.env.require
      self.env.require = function(str)
         self:record_require(str)
         return oldrequire(str)
      end
   end
end

function This:indexat(from, vals, cnts)
   assert(from)
   if self.record_any then
      return function(_, key)
         local got = from[key]
         if got then
            if type(got) == "table" then
               cnts[key] = cnts[key] or {}
               vals[key] = vals[key] or {}
               assert( type(cnts[key]) == "table", "Cant deal with table-to-other changes" )
               return setmetatable({}, {__index = self:indexat(got, vals[key], cnts[key])})
            else
               cnts[key] = (cnts[key] or 0) + 1
               vals[key] = got
               return got
            end
         end
      end
   else
      return from
   end
end

function This:meta(where)
   local cnts, vals = self.cnts[where] or {}, self.vals[where] or {}
   self.cnts[where] = cnts
   self.vals[where] = vals
   return {
      __index = self:indexat(self.env, vals, cnts),
      __newindex = self.allow_global and function(self, to, key)
         error("Trying to set %s from %q, but setting global disabled. ", key, where)
                                         end,
      -- __pairs = function(_) return pairs(self.env) end,
   }
end

-- Poke at a thing as if it is being touched. -- TODO
--function This:poke(file, location)
--   for _, el in pairs(location) do
--   end
--end

-- Copy it. (TODO wait, this is so general to be defaultly in my metas?)
function This:copy() return setmetatable(c.copy_table(self), getmetatable(self)) end

-- From `self.vals` produce something that _only_ has access to those things.
-- (of course, in real use, it assumes all potential accesses have already happened.)
function This:current_only_env()
   -- TODO need a different require-replacement for it.
end

return c.metatable_of(This)
