-- (https://github.com/mason-larobina/luakit/wiki/Play-embedded-video-in-external-player)
----------------------------------------------------------------

local config = globals.use_video_program or {}

local geometry = config.geometry or "1366x768"

-- TODO possible to figure out the maximized geometry properly?
--function maximized_geometry() ... end
--function fullscreen_geometry() ... end
   
local watch_functions = {
   -- Downloads it. TODO does not wait for it... need more general approach..
   youtube_dl = function(view, uri, finish, pop)
      luakit.spawn(string.format("youtube-dl %s -o %s%s'", 
                                 uri, config.download_dir or globals.download_dir or 
                                    capi.download_dir,
                                 "%(uploader)s/%(title)s−%(id)s.%(ext)s").
                      finish)
   end,
   -- View immediately.
   mpv = function(view, uri, finish, pop)
      -- TODO it doesnt listen to `pop`
      if geometry == "fullscreen" then
         luakit.spawn(string.format("mpv --force-window --fs %s", uri), finish)
      else
         luakit.spawn(string.format("mpv --force-window --geometry=%s %s", geometry, uri),
                      finish)
      end
   end,
   cclive = function(view, uri, finish, pop)
      luakit.spawn(string.format("urxvt -e cclive --stream best --filename-format '%%t.%%s' "
               .. "--output-dir %q --exec='mplayer \"%%f\"' %q", os.getenv("HOME") .."/downloads", uri), finish)
   end
}

local which = config.which or "mpv"  -- Allows some pre-defined uses.
local defaultly_vid_fun = config.vid_function or watch_functions[which] or watch_function.mpv

local function vid_function(view, uri, finish, pop)
   if type(uri) == "string" then
      return defaultly_vid_fun(view, uri, finish, pop)
   else
      assert(type(uri) == "table")
      local uri, which = unpack(uri)
      local fun = type(which) == "string" and watch_functions[which] or which
      assert(fun, string.format("Couldnt find function %s %s", uri, which))
      return fun(view, uri, finish, pop)
   end
end


local chain_sequence = {}

-- Whether or not to pop up the window.
local popup_initial = config.popup_initial == nil or config.popup_initial -- First in list.

local function next_in_chain(w, at_end)
   return function()
      table.remove(chain_sequence, 1)
      if #chain_sequence > 0 then
         vid_function(w.view, chain_sequence[1], next_in_chain(w, at_end, config.popup))
      end
   end
end

local chain = config.chain == nil or config.chain
local function add_uri(w, uri)
   local uri = (uri and not (type(uri) == "string" and  string.find(uri, "^ +$")) and uri) or
      w.view.hovered_uri or w.view.uri
   if uri then
      if chain then
         table.insert(chain_sequence, uri)
         if (#chain_sequence) == 1 then -- One left, get it started.
            vid_function(w.view, uri, next_in_chain(w), popup_initial)
         end
      else
         local function endprompt() w:set_prompt("-- VIDEO ENDED --") end
         vid_function(w.view, uri, endprompt, popup_initial)
      end
   end
end

local key, buf, cmd = lousy.bind.key, lousy.bind.buf, lousy.bind.cmd

local use_mod = config.use_mod or {}
local use_key = config.use_key or (config.use_key ~= false and "v")
if use_key then
   add_binds("normal", { key(use_mod, use_key, "View video external program",
                             function(w) add_uri(w) end)  })
end

if config.vid_cmd ~= false then
   add_cmds({ cmd(config.vid_cmd or "vid", "Use external video program on given/current URI",
                  add_uri) })
end

if config.vid_rm_cmd ~= false then
   add_cmds({ cmd(config.vid_rm_cmd or "vid_rm", "Remove video from list",
                  function(w,query)
                     if tonumber(query) then
                        table.remove(chain_sequence, tonumber(query))
                     else
                        w:set_prompt(string.format("Dunno how to use as number: %s", query))
                     end
                  end
) })
end

local vidlist_cmd = config.vidlist_cmd or (config.vidlist_cmd ~= false and "vidlist")
if vidlist_cmd then
   add_cmds({ cmd(vidlist_cmd, "List currently queued video/audio URIs",
                  function(w,query)
                     assert(type(chain_sequence)== "table")
                     local str = ""
                     for i,el in pairs(chain_sequence) do
                        str = str .. tostring(i) .. ":"
                        if type(el) == "table" then
                           str = (str=="" and "" or str .. ",\n") .. table.concat(el, ":")
                        else
                           str = (str=="" and "" or str .. ",\n") .. el
                        end
                     end
                     w:set_prompt(str)
                  end) })
end
