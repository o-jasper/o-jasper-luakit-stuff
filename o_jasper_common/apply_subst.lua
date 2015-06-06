
return function(str, subst)  -- Perhaps something for lousy.util.string
   local n, k = 1, 0
   while n > 0 and k < 256 do
      str, n = string.gsub(str, "{%%([_.:/%w%%]+)}", subst)
      k = k + 1
   end
   return str
end
