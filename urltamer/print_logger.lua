-- Logs by printing everything.

return {
   insert = function(self, info, result)
      if result.redirect then
         print("redirect:", info.uri, "to", result.redirect)
      elseif result.ret then
         print("allow:", info.uri, info.vuri)
      else
         print("block:", info.uri, info.vuri)
      end
   end,
}
