return function(info, result, also_allow)
   require("urltamer.handler").base(info, result, also_allow)
   if not info:own_domain() and not (info.by_userevent or result.specific_allow) then
      result.allow = false
   end
end
