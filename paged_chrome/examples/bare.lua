local chrome_name = "pagedChromeExample"  --pointlessly illegal chars?

local Suggest = require "paged_chrome.Suggest"

local direct = {
   name = "direct",
   -- Suggest using just args.path, allows it to maybe be server-servable in the future.
   -- NOTE: 
   html = function(args, view)
      return string.format([[<p>Direct, no replacements.</p><hr>
<a style="font-size:70%%" href="/%s/templated">to templated</a>]], chrome_name)
   end,
}

-- This is the recommended way.
local templated = {
   name = "templated",

   repl_pattern = [[<p>Templated, using replacements</p>
<p id="add">Javascript -via-lua did <b>not</b> operate</p><hr>
<a style="font-size:70%" href="/{%chrome_name}/direct">to direct</a>

<span style="color:gray;font-size:70%">{%date}</span>

<p>{%auto.html}</p>

<script>document.getElementById("add").innerText = get_str();</script>

<p>All the arg values:({%all_arg_cnt})<p><table>{%all_arg}</table>
<p>All the conf values:({%all_conf_cnt})<p><table>{%all_conf}</table>

<p id="serverlike">Not serverlike/javascript disabled</p>

<script src="/{%chrome_name}/js.js"></script>
]],
   
   to_js = { 
      get_str = function() 
         return function() 
            return "Will enter javascript functions for you"
         end
      end,
   },
   
   repl = function(self, args)
      local all_arg, n = "", 0
      for k, v in pairs(args) do
         all_arg = string.format("%s<tr><td>%s=</td><td>%s</td></tr>",
                                 all_arg, k, v)
         n = n + 1
      end
      local all_conf, m = "", 0
      for k, v in pairs(args.conf) do
         all_conf = string.format("%s<tr><td>%s=</td><td>%s</td></tr>",
                                  all_conf, k, v)
         m = m + 1
      end
      return { chrome_name = chrome_name, date = os.date(),
               all_arg = all_arg,   all_arg_cnt = n,
               all_conf = all_conf, all_conf_cnt = m }
   end,
   
   asset = Suggest.asset,
   asset_fun = Suggest.asset_fun,

   where = {"paged_chrome/examples"}
}

return {
   default_name = "direct",
   chrome_name = chrome_name,

   pages = {
      
      direct = direct,
      
      ["js.js"] = { html=function(...) return [[document.getElementById("serverlike").innerText = "could get src asset";]] end,
                 init=false },
      
      -- Unfortunately have to repeat ourselves here.(`templated` twice)
      -- (well repeat ourselves more to get stuff in variables so indentation decent)
      templated = templated,
   }
}
