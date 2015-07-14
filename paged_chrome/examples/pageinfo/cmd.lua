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
