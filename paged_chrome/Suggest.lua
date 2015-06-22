local apply_subst = require "o_jasper_common.apply_subst"
local asset = require "paged_chrome.asset"

return {

   __name = "paged_chrome.Suggest",

   asset = function(self, file) return asset(self.where, file) end,
   
   asset_fun = function(self) return function(file) return self:asset(file) end end,

   html = function(self, state)
      state.conf = state.conf or {}
      state.conf = state.conf or {}
      local pat = self.repl_pattern and self:pattern(state) or
         asset(self.where, (not state.conf.whole and "body" .. "/" or "") .. self.name)
      
      return apply_subst(pat, self:repl(state))   
   end,

   repl_suggest = function(self, args)
      return { title = string.format("%s:%s", self.chrome_name, self.name) }
   end,

   on_first_visual = function(self, args)
      for name, fun in pairs(self.to_js or {}) do
         args.view:register_function(name, fun(self, name))
      end
   end

   repl = function() error([[Thou shalt not use the base repl list.
`repl_list_suggest` for some suggestions, like title]]) end,
}
