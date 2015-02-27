--  Copyright (C) 17-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.


local lousy = require("lousy")

local function param_val(str)
   if string.match(str, "%d+") then
      return tonumber(str)
   elseif str == "true" or str == "false" then
      return str == "true"
   else
      return str
   end
end

local function param_val_list(input_list, delist)
   local list = {}
   for _, el in pairs(input_list) do table.insert(list, param_val(el)) end
   if #list == 1 and delist then
      return list[1]
   else
      return list
   end
end

local function mn(x)  -- May numerize
   if not x then
      return 0
   elseif type(x) == "boolean" then
      return 1
   else
      return x
   end
end

local function xor(x,y) return (x and not y) or (not x and y) end

function new_result() return { remarks={} } end

local function maybe_hard(way, result, name, yn)
   if yn == "no" then
      table.insert(result.remarks, name)
      result.no =true
      if way.hardno or mn(way.nexthardno) > 0 or way.hard or mn(way.nexthard) <0 then
         return true, false
      end
   elseif yn == "yes" then
      table.insert(result.remarks, name)
      result.yes = true
      if way.hardyes or mn(way.nexthardyes) > 0 or way.hard or mn(way.nexthard) <0 then
         return true, true
      end
   end
end

-- Parametered matches.
function parametered_matches(list, str, info, result, commands, funcs)
   if type(list) == "string" then
      list = lousy.util.string.split(list, "\n")
   end
   local way = {}
   for j, el in pairs(list) do
      result.line_n = j
      result.line = el
      if string.match(el, "^:.+=.+") then -- Indicates setting params.
         local got = lousy.util.string.split(el, "=")
         way[string.sub(got[1], 2)] = param_val_list(lousy.util.string.split(got[2], " "),
                                                     true)
      elseif string.match(el, "^:.+") then  -- Call a function
         local got = param_val_list(lousy.util.string.split(el, " "))
         assert(got[1], string.format("%d %s %s", #got, got[1], el))
         local name = string.sub(got[1], 2)
         local cmd = commands[name] or commands.wrong
         local now, ret = maybe_hard(way, result, name,
                                     cmd.fun(way, info, result, got))
         if now then return ret, result end
      elseif el ~= "" then
         if xor(string.match(str, el), way.invert or (mn(way.nextinvert) > 0)) then
            way.pat = el  --  The pattern.
            -- Run through current functions.
            for _, fun in ensure_pairs(way.fun) do
               -- Whether to take the current result.
               local func = funcs[fun]
               if func then
                  local now, ret = maybe_hard(way, result, fun, func.fun(way, info, result))
                  if now then return ret, result end
               end
            end
         end
         -- Countdowns.
         way.nexthard    = mn(way.nexthard)   - 1
         way.nexthardno  = mn(way.nexthard)   - 1
         way.nexthardyes = mn(way.nexthard)   - 1
         way.nextinvert  = mn(way.nextinvert) - 1
      end
   end
   local weak = result.weakyes and not result.weakno
   return (result.yes or weak) and not result.no, result
end
