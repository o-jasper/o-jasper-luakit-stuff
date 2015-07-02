return function(mirror)
   local cmd = require("lousy").bind.cmd
   
   local function mirror_cmd(w, arg)
      local clobber = arg and string.match(arg, "^nc ?")
      if clobber then
         arg = string.sub(arg, #clobber)
      end
      mirror:do_uri((arg and #arg > 0 and arg) or w.view.uri)
   end
   
   local function open_cmd(w, query)
      if mirror.notice_open then mirror:notice_open(query or w.view.uri) end
      w:new_tab(w:search_open(mirror:dir(query or w.view.uri)))
   end

   --Starting with nc it will no-clobber, not overwrite.
   add_cmds({ lousy.bind.cmd("mirror", "Mirrors using `wget`",
                             mirror_cmd),
              lousy.bind.cmd("open_mirror","Mirrors using `wget`", open_cmd) })
end
