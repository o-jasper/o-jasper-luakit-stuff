-- NOTE both seem still subject to change.
local Pegasus = require 'pegasus'
-- NOTE: thats my pull request, does not reflect on pegasus.
-- (infact somewhat likely not getting pulled)
local PegasusJs = require 'PegasusJs'

local Suggest = require "paged_chrome.Suggest"

return function(register)
   local server = Pegasus:new()

   local function help_if_not_found(chrome, args)
      --html = string.format("<p>Try.. %d</p> %s %s %s <p>%s %s</p>", k, req.path,
      -- t, t2, args.page, args.path)
      local html = "Dont have this..<h4>args:</h4><table>"
      for k, v in pairs(args) do
         html = html .. string.format("<tr><td>%s =</td><td>%s</td></tr>", k,v)
      end
      html = html .. "</table>"
      if not chrome then  -- TODO link them too.
         html = html .. 
            string.format("<p>Dont have chrome %s, to have chromes:</p><table>",
                          chrome_name)
         for k, v in pairs(register.sites) do
            local val = v.chrome_name == k  and v.chrome_name or
               string.format("%s != %s", k, v.chrome_name)
            html = html .. string.format([[<tr><td><a href="/%s/">%s</a></td></tr>]],
               val, val)
         end
      else
         html = html .. string.format("<p>Dont have page %s, to have pages:</p><table>",
                                      args.page)
         for k in pairs(chrome.pages) do
            html = html .. string.format([[<tr><td><a href="/%s/%s">%s</a></td></tr>]],
               args.chrome_name, k, k)
         end
      end
      return html .. "</table>"
   end
   
   -- TODO/NOTE: fairly messy, 
   local js_interface = {}
   server:start(function(req, rep)
         -- See if need to serve up any of the javascript responses.
         -- TODO this should follow from the directory, not trying them all.
         for k,js in pairs(js_interface) do
            if js:respond(req, rep) then return end
         end

         -- Get at information.
         local _,t = string.find(req.path, "/", 2, true)
         local chrome_name = t and string.sub(req.path, 2, t - 1) or ""
         local _, t2 = t and string.find(req.path, "/", t + 1, true)
         local args = {
            chrome_name = chrome_name,
            page = string.sub(req.path, t and t + 1 or 2, t2 and t2 - 1),
            --uri  = req.,  --how?
            path = t2 and string.sub(req.path, t2 + 1) or "",
            whole = true,
            --view  = "touching this limits server-ability",
            --conf
         }
         -- Figure the page, if not, give help.
         local chrome = register.sites[chrome_name]
         local page = chrome and chrome.pages[args.page]
         if not page then
            rep:addHeader('Content-Type', 'text/html'):write(help_if_not_found(chrome, args))
            return
         end

         -- Make the javascript interfacing, as needed..
         local chr_dir = string.format("/%s/%s", chrome_name, args.page)
         local js = js_interface[chr_dir]
         if not js then
            js = PegasusJs.new{string.format("%s/PegasusJs", chr_dir)}
            local funs = (type(page.to_js) == "function" and page:to_js()) or
               page.to_js or {}
            local add_funs = {}
            for k,v in pairs(funs) do add_funs[k] = v(page) end
            js:add(add_funs)
            js_interface[chr_dir] = js
         end

         -- Injection of the javascript needed to interface.
         args.inject = string.format(
            [[<script type="text/javascript" src="%s/PegasusJs/index.js"></script>]],
            chr_dir
         )
         local html = (page.html or Suggest.html)(page, args)
         rep:addHeader('Content-Type', 'text/html'):write(html)
   end)
end
