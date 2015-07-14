local add_1 = require "paged_chrome.chrome.add_1"

return function(register)
   assert(register.sites)
   for k,v in pairs(register.sites) do 
      assert(v.chrome_name == k)
      add_1(v)
   end
end
