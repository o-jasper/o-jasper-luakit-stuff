local config = globals.doc or {}

-- Some of the commented-outs should be caught by a pattern.
local dict = {
--lua     = "file:///usr/share/doc/lua/manual.html",
   py      = "file:///usr/share/doc/python/html/index.html",
--python  = "file:///usr/share/doc/python/html/index.html",
   pylib   = "file:///usr/share/doc/python/html/library/index.html",
   pylang  = "file:///usr/share/doc/python/html/reference/index.html",
   polipo  = "file:///usr/share/polipo/www/doc/index.html",
}

for k,v in pairs(config.urls or {}) do dict[k] = v end  -- `false` is allowed.

local otherwise_patterns = config.otherwise_patterns or {
   "/usr/share/doc/%s/index.html",
   "/usr/share/doc/%s/ref.html",
   "/usr/share/doc/%s/reference.html",
   "/usr/share/doc/%s/manual.html",

   "/usr/share/doc/%s/html/index.html",
   "/usr/share/doc/%s/html/ref.html",
   "/usr/share/doc/%s/html/reference.html",
   "/usr/share/doc/%s/html/manual.html",

   "/usr/share/gtk-doc/html/%s/index.html",
}

local function find_otherwise(query)
   -- It is tad limited!
   for _, pat in ipairs(otherwise_patterns) do
      local fd = io.open(string.format(pat, query))
      if fd then fd:close() return "file://" .. string.format(pat, query) end
   end
end

local cmd = lousy.bind.cmd

add_cmds( {
      cmd("doc", "Various documentation",
          function(w, query)
             local got = dict[query] or find_otherwise(query)
             if got then
                w:new_tab(got)
             else
                w:set_prompt("Couldnt find doc")
             end
      end)
})
