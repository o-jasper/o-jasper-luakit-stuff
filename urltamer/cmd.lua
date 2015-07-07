local cmd = lousy.bind.cmd

add_cmds({ cmd("urltamer_reload",
               function()
                  print("... reloading")
                  require("urltamer.matchers").reload()
              end),
})
