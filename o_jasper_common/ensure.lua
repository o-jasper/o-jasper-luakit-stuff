local ensure = {
   table = function(x) 
      if not x then return {} end
      if type(x) == "table" then return x else return {x} end 
   end,
}

function ensure.pairs(x) 
   if type(x) =="function" then return x else return pairs(ensure.table(x)) end
end

return ensure
