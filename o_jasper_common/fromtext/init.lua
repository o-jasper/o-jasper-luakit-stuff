local function index(self, key)  -- Get until we got it.
   for name in pairs({"searchlike", "time", "uri"}) do
      for k,v in pairs(require("o_jasper_common." .. name)) do
         self[k] = v
      end
      if self[k] then return self[k] end
   end
end

return setmetatable({}, { __index = index })
