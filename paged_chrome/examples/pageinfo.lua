-- Uses javascript to extract a bunch of information, and then 
-- shows it back.

local Public = {
   chrome_name = "pageInfo",
   chrome_uri  = "luakit://{%chrome_name}",
   title       = "{%chrome_name}",

   default_name = "view",
}

local data

-- Think the things that crash do so because the sequence item not 
--  translated into lua properly?
local acquire = {
   referrer = "document.referrer",
   --anchors = "document.anchors",  -- crash
   anchors_cnt = "document.anchors.length",
--   links     = "document.links",
   links_cnt = "document.links.length",

--   applets     = "document.applets",
   applets_cnt = "document.applets.length",
--   embeds      = "document.embeds",
   embeds_cnt  = "document.embeds.length",
   cookie      = "document.cookie",
   cookie_cnt  = "document.cookie.length",
   --images  = "document.images", -- crash
   images_cnt = "document.images.length",
}

local cmd = lousy.bind.cmd
add_cmds({ cmd("pageinfo", function(w, query)
                  data = {}  -- Sluurp
                  for k,v in pairs(acquire) do data[k] = w.view:eval_js(v) end
                  w:new_tab("luakit://" .. Public.chrome_name .. "/view")
              end) 
})

local html = require "o_jasper_common.html"

local function list_text(list, name, between)
   local ret = {}
   for k, el in ipairs(list) do
      table.insert(ret, tostring(type(el) == "table" and el[name] or el))
   end
   return table.concat(ret, between or ", ")
end

Public.pages = {
   default_name = "view",
   view = {
      name = "view",
      where = "paged_chrome/examples",
      
      repl = function(self, args)
         for k,v in pairs(info) do data[k] = v end
         --data.anchors_name_list = list_text(data.anchors, "name")
         --data.img_href_list = list_text(data.images, "href", "<br>")

         data.cookie_table = data.cookie --html.table(data.cookie)
         return data
      end,
   }
}

return Public
