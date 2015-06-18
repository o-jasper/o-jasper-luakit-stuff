-- Messy: not sure of direction at this point.
-- Figuring trying restrictive.

local c  = require "o_jasper_common.meta"

local SimpleBase = require "alt_require.ah.SimpleBase"
local This = c.copy_meta(SimpleBase)
This.__name = "alt_require.ah.Table"

This.new_remap = { "env" }

This.new_defaults = { 
   env = SimpleBase.new_defaults.env,
   cnts = {},
   vals = {}, 
   cnts_require = {},
   loaded = {},
}

--This.disallow_global = false
This.record_require_file = true
This.record_any = true
This.recurse = true
This.mode = "record"

function This:record_require(str)
   self.cnts_require[str] = (self.cnts_require[str] or 0) + 1
end

function This:init()
   if self.recurse then
      self.env = self.env or {}
      self.env.require = self:require_fun()
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

function This:_ensure_tablestarts(file)
   local cnts, vals = self.cnts[file] or {}, self.vals[file] or {}
   self.cnts[file] = cnts
   self.vals[file] = vals
   return cnts, vals
end

function This:_newindex(file)
   return self.disallow_global and function (_, _, key)
      error("Trying to set %s from %q, but setting global disabled. ", key, file)
   end
end

function This:meta(file)
   local cnts, vals = self:_ensure_tablestarts(file)
   return {
      __index = self:indexat(self.env, vals, cnts),
      __newindex = self:_newindex(file),
      -- __pairs = function(_) return pairs(self.env) end,
   }
end

function This:assumed_require_fun(file)
   -- TODO use the information in values.
   return vals[file]  -- Right.. dead-simple.
end

function This:enforced_indexat(from, cnts)
   assert(from)
   return function(_, key)
      if cnts[key] then
         local got = from[key]
         if type(got) == "table" then
            return setmetatable({},
               {__index = self:enforced_indexat(got, cnts[key])})
         else
            return got
         end
      else
         error("aint allowed here")
      end
   end
end

function This:enforced_meta(file)
   local cnts = self.cnts[file]
   if not cnts then error("disallowed require %q", file) end

   return {
      __index = self:enforced_indexat(self.env, cnts),
      __newindex = self:_newindex(file),
   }
end

function This:enforced_require_fun(file)
   return self.require_fun(self.enforced_meta)
end

function This:require_fun(file, mode)
   local mode = self.mode or more
   if mode == "record" then
      return SimpleBase.require_fun(self, file)
   elseif mode == "enforce" then
      return self:enforced_require_fun(file)
   elseif mode == "assume" then
      return self:assumed_require_fun(file)
   else
      error("Aint got mode %s", mode)
   end
end

-- Finds the place to poke
function This:info_at_spot(file, location)
   local cnts, vals = self:_ensure_tablestarts(file)
   local got = self:require(file)
   local i = 1
   for _, k in pairs(location) do
      if type(got) == "table" and cnts[k] == "table"then
         assert(vals[k] == "table")
         got = got[k]
         local next_cnts, next_vals = cnts[k] or {}, vals[k] == nil and {} or vals[k]
         cnts[k] = next_cnts
         vals[k] = next_vals
      else
         return false  -- Already a non-tabe thing there.
      end
   end
   return true, got, cnts, vals
end

-- TODO dubious mess..
-- Poke at a thing as if it is being touched. 
function This:poke(file, location, way)
   local final_lo
   way = way or {}
   local cnts, vals = self:_ensure_tablestarts(file)
   local got = self:require(file)
   local i = 1
   while i < #location -1 do
      local k = location[i]
      if type(got) == "table" then
         got = got[k]
         local next_cnts, next_vals = cnts[k] or {}, vals[k] == nil and {} or vals[k]
         cnts[k] = next_cnts
         vals[k] = next_vals
      else
         return "nothing to reach"  -- Failure, cant go deeper.
      end
      i = i + 1
   end
   local k = location[i]
   vals[k] = vals[k] == nil and {} or vals[k]
   if getmetatable(got[k]) and way.w_meta and way.w_meta == "disallow" then
      return "disallow metatables"
   end
   if type(got[k]) == "table" then  -- TODO Hrmm..
      if vals[k] and type(vals[k]) ~= "table" then
         return "incompatible to set as table"
      end
      if way.table == "disallow" then 
         return "disallow tables"
      elseif way.table == "via pairs" then
         vals[k] = vals[k] or {}
         for k2,v in pairs(got[k]) do
            vals[k][k2] = v
         end
      elseif way.table == "set, no meta" then
         if getmetatable(vals[k])  then return "disallow meta" end
         vals[k] = got[k]
      elseif way.table == nil or way.table == "set" then
         vals[k] = got[k]
      else
         error("Dont know what to do with %s for `way.table`", way.table)
         return "fail"
      end
   else
      vals[k] = got[k]
   end
   return "success"
end

return c.metatable_of(This)
