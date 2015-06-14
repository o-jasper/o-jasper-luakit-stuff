
local req_print = require("alt_require.ah.SimplePrintLog").new()

req_print:require("alt_require.test.reqme")

print("-----------")
local req_table = require("alt_require.ah.SimpleTableLog").new()

req_table:require("alt_require.test.reqme")

print(#req_table.recorded_require, #req_table.recorded)
for k,v in pairs(req_table.recorded_require) do
   print("req", k, v)
end
for k,v in pairs(req_table.recorded) do
   for k2, v in pairs(v) do
      print(k, k2, v)
   end
end
