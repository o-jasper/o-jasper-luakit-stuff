local lfs = require "lfs"

local Public = {
   chrome_name = "bareDirChrome",
   default_name = "nopage",

   chrome_uri  = "luakit://{%chrome_name}",
   title       = "{%chrome_name}",
}

Public.pages = {
   nopage = {
      name = "nopage",
      to_js = {},
      repl_pattern = [[<h1>Directory viewer</h1>
Use this to view directories, by going to 
<a href="{%chrome_uri}/dir/">{%chrome_uri}/dir/</a>]],
      repl = function(_, _, _) return Public end
   },
   dir = {
      name = "dir",
      where = "paged_chrome/examples",
      to_js = {},
      --repl_pattern="{%dir.html}",
      repl = function(self, meta, _)
            local ret = {}
            for k,v in pairs(Public) do ret[k] = v end
            ret.directory = string.sub(meta.path, 4)
            if ret.directory == "" then
               ret.directory = lfs.currentdir()
            end
            ret.list = ""
            for k,v in lfs.dir(ret.directory) do
               local attr = lfs.attributes(ret.directory .. "/" .. k)
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
               else
                  add = string.format("<td>Cant get attributes?? {%%directory}/%s </td>", k)
               end
               ret.list =  ret.list .. add .. "</tr>"
            end
            return ret
      end
   },
}

return Public
