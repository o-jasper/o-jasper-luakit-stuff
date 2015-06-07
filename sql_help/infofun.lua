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

function Public.entry_highest_priority(creator, entry, infofuns)
   local list = {}
   for key, fun in pairs(infofuns or creator:config().infofuns) do
      local got = fun.maybe_new(creator, entry)
      if got then table.insert(list, got) end
   end
   return Public.infofun_highest_priority(list)
end

function Public.thresh_priority(creator, entry, infofuns, thresh)
   local ret = {}
   for key, fun in pairs(infofuns or creator:config().infofuns) do
      local got = fun.maybe_new(creator, entry)
      if got and got:priority() > thresh then table.insert(ret, got) end
   end
   return ret
end

local function fun_on_each(fun)
   return function (creator, list, infofuns)
      local ret = {}
      for _, entry in pairs(list) do
         for _, el in pairs(fun(creator, entry, infofuns)) do
            table.insert(ret, el)
         end
      end
      return ret
   end
end

Public.list_highest_priority_each = fun_on_each(Public.entry_highest_priority)
Public.list_thresh_priority = fun_on_each(Public.entry_highest_priority)

return Public
