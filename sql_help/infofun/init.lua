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

local function newlist(fun, creator, entry)
   if fun.newlist then
      return fun.newlist(creator, entry) or {}
   else  -- Defaults to just creating one and stuffing the creator on.
      return {fun.new({ creator = creator, e=entry })}
   end
end

function Public.entry_highest_priority(creator, entry, infofuns, into)
   into = into or {}
   for key, fun in pairs(infofuns or creator:config().infofuns) do
      for _, el in pairs(newlist(fun, creator, entry)) do
         table.insert(into, el)  -- Add all of them.
      end
   end
   return Public.infofun_highest_priority(into)
end

function Public.entry_thresh_priority(creator, entry, infofuns, thresh, into)
   into = into or {}
   for key, fun in pairs(infofuns or creator:config().infofuns) do
      for _, el in pairs(newlist(fun, creator, entry)) do
         if el:priority() > thresh then-- Add those with sufficient priority.
            table.insert(into, el)  
         end
      end
   end
   return into
end

local function fun_on_each(fun)
   return function (creator, list, infofuns, ...)
      local ret = {}
      for _, entry in pairs(list) do
         for _, el in pairs(fun(creator, entry, infofuns, ...)) do
            table.insert(ret, el)
         end
      end
      return ret
   end
end

Public.list_highest_priority_each = fun_on_each(Public.entry_highest_priority)
Public.list_thresh_priority = fun_on_each(Public.entry_thresh_priority)

function Public.priority_sort(list, priority_override)
   local function default_compare(a, b)
      return (priority_override or a.priority)(a) > (priority_override or b.priority)(b)
   end
   table.sort(list, default_compare)
   return list
end

return Public
