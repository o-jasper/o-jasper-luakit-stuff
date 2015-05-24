local domain_of_uri = require("o_jasper_common.fromtext.uri").domain_of_uri

return {
   fancy_uri = function(uri, arounds)
      if not uri then return " " end
      local domain = domain_of_uri(uri)
      local i, j = string.find(uri, domain, 1, true)
      if not i then 
         return uri
      end
      around = around or {}
      for _,v in pairs({"first", "domain", "file"}) do
         around["pre_" .. v] = around["pre_" .. v] or 
            string.format([[<span class="uri_part_%s">]], v)
         around["post_" .. v] = around["post_" .. v] or "</span>"
      end
      
      return
         around.pre_first  .. string.sub(uri, 1, i - 1) .. around.post_first  ..
         around.pre_domain .. string.sub(uri, i, j)     .. around.post_domain ..
         around.pre_file   .. string.sub(uri, j + 1)    .. around.post_file
   end,
}
