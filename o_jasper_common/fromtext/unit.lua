return {
   w_magnitude_interpret = function(text)
      if string.match(text, "^[%d]+[ ]*[numkMGT]*$") then
         local name = string.match(text, "[numkMGT]*$")
         local factor = ({p=1e-12, n=1e-9, u=1e-6, m=1e-3, 
                          k=1e3, M=1e6, G=1e9, T=1e12})[name] or 1
         return tonumber(string.match(text, "^[%d]+"))*factor
      end
   end,
}
