local function index(self, key)  -- Get until we got it.
   for name in pairs({searchlike=true, time=true, uri=true, unit=true}) do
      for k,v in pairs(require("o_jasper_common.fromtext." .. name)) do
         self[k] = v
      end
      if rawget(self, key) then return rawget(self, key) end
   end
end

return setmetatable({}, { __index = index })
