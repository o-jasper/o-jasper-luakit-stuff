--local apply_repl = require "o_jasper_common.apply_repl"

return function(info, state, direct, fun_table, pattern_table)
   pattern_table  = pattern_table or {}
   priority_table = priority_table or {}
   local function find_in_patterns(key)
      for k,v in pairs(pattern_table) do
         if string.match(key, k) then return v end
      end
   end
   local meta = {
      __index = function(_, key)
         local got = fun_table[key] or find_in_patterns(key) or fun_table.default
         if got then
            if type(got) == "function" then
               return got(info, state, key)
            elseif type(got) == "table" then  -- List of things, each a priority.
               local cur, best_priority = nil, 0
               for _,fun in pairs(got) do
                  local result, priority = fun(info, state, key, best_priority, state.config)
                  if result and priority > best_priority then
                     best_priority = priority
                     cur = result
                  end
               end
               return cur
            else  -- Just a plain value.
               return got
            end
         end
      end,
      -- Dont do this, if people use it this way, it obscures the fact that is is just
      -- a table externally. (their source shouldnt "know" about this.)
      -- __call = function(self, str) 
      --   return require("o_jasper_common.apply_repl")(str, self)
      -- end
   }
   return setmetatable(direct, meta)
end
