local config = globals.urltamer or {}

return function(info, result, also_allow)
   if info.uri == "about:blank" or info.by_userevent then
      result.allow = true
   elseif also_allow and info:uri_match(also_allow) then  -- (Doesnt excuse tardiness)
      result.specific_allow = true
      result.allow = true
   elseif info.dt > config.late_dt  or info:uri_match({"^.+[.][fF][lL][vV]$", "^.+[.][sS][wW][fF]$"}) then
      result.was_late = true
      result.allow = false
   else
      result.allow = true
   end
end
