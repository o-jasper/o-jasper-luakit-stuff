local chrome_name = "pagedChromeExample"  --pointlessly illegal chars?

local Suggest = require "paged_chrome.Suggest"

local direct = {
   name = "direct",
   -- Suggest using just args.path, allows it to maybe be server-servable in the future.
   -- NOTE: 
   html = function(args, view)
      return string.format([[<p>Direct, no replacements.</p><hr>
<a style="font-size:70%%" href="luakit://%s/templated">to templated</a>]], chrome_name)
   end,
}

-- This is the recommended way.
local templated = {
   name = "templated",

   repl_pattern = [[<p>Templated, using replacements</p>
<p id="add"></p><hr>
<a style="font-size:70%" href="luakit://{%chrome_name}/direct">to direct</a>

<span style="color:gray;font-size:70%">{%date}</span>

<p>{%auto.html}</p>

<script>document.getElementById("add").innerText = get_str();</script>
<script src="luakit://{%chrome_name}/js.js"></script>
]],
   
   to_js = { 
      get_str = function() 
         return function() 
            return "Will enter javascript functions for you"
         end
      end,
   },
   
   repl = function(args, view)
      return { chrome_name = chrome_name, date = os.date() }
   end,
   
   asset = Suggest.asset,
   asset_fun = Suggest.asset_fun,

   where = {"paged_chrome/examples"}
}

local pages = {
   default_name = "direct",
   direct = direct,

   ["js.js"] = { html=function(...) return [[alert("This probably wont execute.");]] end,
                 init=false },

   -- Unfortunately have to repeat ourselves here.(`templated` twice)
   -- (well repeat ourselves more to get stuff in variables so indentation decent)
   templated = templated,
}

local paged_chrome = require"paged_chrome"
paged_chrome.chrome(chrome_name, pages)
