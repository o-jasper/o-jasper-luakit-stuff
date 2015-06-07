local Public = {}

function Public.infofun_highest_priority(infofun_list)
   local best, best_priority = nil, nil
   for _, got in pairs(infofun_list) do
      local priority = got:priority()
      if not best or priority > best_priority then
         best = got
         best_priority = priority
      end
   end
   return best and {best} or {}
end

function Public.entry_highest_priority(entry, infofuns, config)
   local list = {}
   for key, fun in pairs(infofuns or self:config().infofuns) do
      local got = fun.maybe_new(entry, config)
      if got then table.insert(list, got) end
   end
   return Public.infofun_highest_priority(list)
end

function Public.thresh_priority(entry, infofuns, config, thresh)
   local ret = {}
   for key, fun in pairs(infofuns or self:config().infofuns) do
      local got = fun.maybe_new(entry, config)
      if got and got:priority() > thresh then table.insert(ret, got) end
   end
   return ret
end

local function fun_on_each(fun)
   return function (list, infofuns, config)
      local ret = {}
      for _, entry in pairs(list) do
         for _, el in pairs(fun(entry, infofuns, config)) do
            table.insert(ret, el)
         end
      end
      return ret
   end
end

Public.list_highest_priority_each = fun_on_each(Public.entry_highest_priority)
Public.list_thresh_priority = fun_on_each(Public.entry_highest_priority)

return Public
