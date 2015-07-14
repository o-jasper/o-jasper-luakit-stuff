local Pegasus = require 'pegasus'
local pages = req

local Suggest = require "paged_chrome.Suggest"

return function(register)
   local server = Pegasus:new()
   
   server:start(function (req, rep)
         local _,t = string.find(req.path, "/", 2, true)
         local chrome_name = t and string.sub(req.path, 2, t - 1) or ""
         local _, t2 = string.find(req.path, "/", t + 1, true)
         local args = { 
            chrome_name = chrome_name,
            page = string.sub(req.path, t + 1, t2 and t2 - 1),
            --uri  = req.,  --how?
            path = t2 and string.sub(req.path, t2 + 1) or "",
            whole = true,
            --view  = "keep your hands off me",
            --conf
         }
         local html = ""
         local chrome = register.sites[chrome_name]
         local page = chrome and chrome.pages[args.page]
         if page then
            html = (page.html or Suggest.html)(page, args)
         else
            --html = string.format("<p>Try.. %d</p> %s %s %s <p>%s %s</p>", k, req.path,
            -- t, t2, args.page, args.path)
            html = "Dont have this..<h4>args:</h4><table>"
            for k, v in pairs(args) do
               html = html .. string.format("<tr><td>%s =</td><td>%s</td></tr>", k,v)
            end
            if not chrome then
               local list = {}
               for k,v in pairs(register.sites) do
                  table.insert(list, v.chrome_name == k  and v.chrome_name or
                                  string.format("%s != %s", k, v.chrome_name))
                  if k == chrome_name then table.insert(list, "hmm") end
               end
               html = html .. string.format("</table><h4>List of chromes(%d):</h4>%s",
                                            #list, table.concat(list, ", <br>"))
            else
               html = html .. "TODO list the pages.."
            end
         end

         rep:addHeader('Content-Type', 'text/html'):write(html)
   end)
end
