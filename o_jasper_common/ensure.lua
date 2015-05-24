local Public = {
   table = function(x) 
      if not x then return {} end
      if type(x) == "table" then return x else return {x} end 
   end,
}

function Public.pairs(x) 
   if type(x) =="function" then return x else return pairs(Public.ensure_table(x)) end
end

return Public
