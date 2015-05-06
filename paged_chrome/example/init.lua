local paged_chrome = require"paged_chrome"

local chrome_name = "pagedChromeExample"  --pointlessly illegal chars?

local direct = {
   -- Suggest using just args.path, allows it to maybe be server-servable in the future.
   -- NOTE: 
   html = function(args, view)
      return string.format([[<p>Direct, no replacements.</p><hr>
<a style="font-size:70%%" href="luakit://%s/templated">to templated</a>]], chrome_name)
   end,
   init = false,  -- To say we dont need an init.
}

-- This is the recommended way.
local templated = {
   repl_pattern = [[<p>Templated, using replacements</p>
<p id="add"></p><hr>
<a style="font-size:70%" href="luakit://{%chrome_name}/direct">to direct</a>

<span style="color:gray;font-size:70%">{%date}</span>

<p>{%auto.html}</p>

<script>document.getElementById("add").innerText = get_str();</script>
]],
   
   to_js = { 
      get_str = function() 
         return function() 
            return "Will enter javascript functions for you"
         end
      end,
   },
   
   repl_list = function(args, view)
      return { chrome_name = chrome_name, date = os.date() }
   end,

   where = {"paged_chrome/example"}
}

local pages = {
   default_name = "direct",
   direct = direct, 
   -- Unfortunately have to repeat ourselves here.(`templated` twice)
   -- (well repeat ourselves more to get stuff in variables so indentation decent)
   templated = paged_chrome.templated_page(templated, "templated"),
}

paged_chrome.paged_chrome(chrome_name, pages)
