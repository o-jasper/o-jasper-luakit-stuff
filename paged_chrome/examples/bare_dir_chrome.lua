local lfs = require "lfs"
local paged_chrome = require("paged_chrome")

local info = {
   chrome_name = "bareDirChrome"
}

local pages = {
   default_name = "nopage",
   nopage = paged_chrome.templated_page({
      to_js = {},
      repl_pattern = [[<h1>Directory viewer</h1>
Use this to view directories, by going to 
<a href="luakit://{%chrome_name}/dir/">luakit://{%chrome_name}/dir/</a>]],
      repl_list = function(_, _, _) return info end
   }, "nopage"),
   dir = paged_chrome.templated_page({
      to_js = {},
      repl_pattern = [[<h1>Dir: {%directory}</h1>
<table>{%list}</table>]],
      repl_list = function(self, meta, _)
            local ret = {}
            for k,v in pairs(info) do ret[k] = v
            ret.directory = string.sub(meta.path, 4)
            ret.list = ""
            if ret.directory == "" then
               ret.directory = lfs.currentdir() 
            end
            for k,v in lfs.dir(ret.directory) do
               ret.list = ret.list .. string.format("<tr><td>%s</td><td>%s</td></tr>", k,v)
            end
            return ret
      end,
   }, "dir")
}
paged_chrome.paged_chrome(info.chrome_name, pages)
