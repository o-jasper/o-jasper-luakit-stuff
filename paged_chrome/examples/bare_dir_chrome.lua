local lfs = require "lfs"
local paged_chrome = require("paged_chrome")

local info = {
   chrome_name = "bareDirChrome",
   chrome_uri  = "luakit://{%chrome_name}",
}

local pages = {
   default_name = "nopage",
   nopage = paged_chrome.templated_page({
      to_js = {},
      repl_pattern = [[<h1>Directory viewer</h1>
Use this to view directories, by going to 
<a href="{%chrome_uri}/dir/">{%chrome_uri}/dir/</a>]],
      repl_list = function(_, _, _) return info end
   }, "nopage"),
   dir = paged_chrome.templated_page({
      to_js = {},
      repl_pattern = [[<h1>Dir: {%directory}</h1>
<table>{%list}</table>
<hr>
<p><a href="{%chrome_uri}">{%chrome_uri}</a></p>
]],
      repl_list = function(self, meta, _)
            local ret = {}
            for k,v in pairs(info) do ret[k] = v end
            ret.directory = string.sub(meta.path, 4)
            ret.list = ""
            if ret.directory == "" then
               ret.directory = lfs.currentdir()
            end
            for k,v in lfs.dir(ret.directory) do
               local attr = lfs.attributes(k)
               local add = "<tr>"
               if attr and attr.mode == "directory" then
                  add = string.format(
                     [[<td><a href="{%%chrome_uri}/dir{%%directory}/%s">%s/</a></td>]],
                     k, k)
               else
                  add = string.format(
                     [[<td><a href="file://{%%directory}/%s">%s</a></td>]],
                     k,k)
               end
               if attr then
                  add = string.format("%s<td>%d</td><td>%s</td>", 
                                      add, attr.size, os.date("%c", attr.modification))
               end
               ret.list = ret.list .. add .. "</tr>"
            end
            return ret
      end
   }, "dir")
}
paged_chrome.paged_chrome(info.chrome_name, pages)
