
return {
   plus_cmd_add = function(ret, log)
      local cmd_add = log.cmd_add or {}
      for _,k in pairs({"uri", "title", "desc"}) do  -- Ill conceived but harmless.
         ret["cmd_add_" .. k] = cmd_add[k] or ""
      end
      ret.cmd_add_gui = log.cmd_add and "true" or "false"
      log.cmd_add = nil
   end
}
