-- TODO.. the pattern is a bit arbitrary.
local function full_gsub(str, subst)  -- Perhaps something for lousy.util.string
   local n, k = 1, 0
   while n > 0 and k < 256 do
      str, n = string.gsub(str, "{%%([_./%w]+)}", subst)
      k = k + 1
   end
   return str
end

return full_gsub
