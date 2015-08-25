Use some program to view videos. Default is `mpv`, binding 
to the command `:vid` and the key `v`, using the hovered url or current url.
`vidlist` shows the list in the queue.

## Configuration
Gets info from `globals.use_video_program`

`.vid_cmd` the command as vid, default `"vid"`,
uses the argument string. 

`.use_mod`, `use_key` keybinding. the latter `false` disabled the v-key default.

`.vid_cmd` command to run it.

`.vid_rm_cmd` command to remove one.(numbered)

`.vidlist_cmd`, the command to look at the list 

`.which` selects a program. Got basic one for `mpv` and `cclive`,
latter scarcely tested.

### Adding 
`.vid_function` provide your entire program-running function. If it is good,
consider pull-requesting so people can use `.which` to select it.

## TODO
* If argument string of `:vid` is empty should look at hovered/current uri..
* `:vid_rm` to remove things off the list?
