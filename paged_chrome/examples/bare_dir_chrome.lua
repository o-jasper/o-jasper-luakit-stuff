local lfs = require "lfs"
local paged_chrome = require("paged_chrome").paged_chrome

local info = {
   chrome_name = "dirChrome"
}

local pages = {
   default="nopage",
   nopage = templated_page({
      to_js = {},
      repl_pattern = [[<h1>Directory viewer</h1>
Use this to view directories, by going to luakit://{%chrome_name}/dir/somedir"]],
      repl_list = function(meta, _) return info end,
   })
   dir = templated_page({
      to_js = {},
      repl_pattern = [[<h1>Dir: {%directory}</h1>
<table>{%list}</table>]],
      repl_list = function(meta, _)
            info.list = ""
            for k,v in pairs(lfs.dir(string.sub(meta.uri, 8 + #info.chrome_name))) do
               info.list = info.list .. string.format("<tr><td>%s</td><td>%s</td></tr>")
            end
            return info
      end,
   })
}
paged_chrome(info.chrome_name, pages)
