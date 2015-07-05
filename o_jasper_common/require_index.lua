local function ret(prep) 
   return function(self, key)
      return require(prep .. "." .. key)
   end 
end

return ret
