
local tab = require("alt_require.ah.Table").new()

tab:require("alt_require.test.reqme")

local function str_tab(tab, prep)
   local ret, prep = "", prep or "  "
   for k, v in pairs(tab) do
      if type(v) == "table" then
         ret = ret .. prep .. tostring(k) .. ":\n" .. str_tab(v, "  " .. prep)
      else 
         ret = ret .. prep .. string.format("%s: %s\n", k, v)
      end
   end
   return ret
end

print("r")
print(str_tab(tab.cnts))
print(str_tab(tab.vals))

tab.mode = "enforce"
tab:require("alt_require.test.reqme")
