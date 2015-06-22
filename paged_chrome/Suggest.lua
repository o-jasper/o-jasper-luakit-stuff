local apply_subst = require "o_jasper_common.apply_subst"
local asset = require "paged_chrome.asset"

return {

   __name = "paged_chrome.Suggest",

   asset = function(self, file) return asset(self.where, file) end,
   
   asset_fun = function(self)
      return self.where and function(file) return self:asset(file) end
   end,

   html = function(self, state)
      state.conf = state.conf or {}
      local pat
      if type(self.repl_pattern) == "function" then
         pat = self:pattern(state)
      elseif type(self.repl_pattern) == "string" then
         pat = self.repl_pattern
      else         
         pat = asset(self.where, (not state.conf.whole and "body" .. "/" or "") .. self.name)
      end

      local repl = self:repl(state)
      local asset_fun = state.conf.asset_fun or self.asset_fun and self:asset_fun()
      if asset_fun then
         local function index(_, key) return repl[key] or asset_fun(key) end
         return apply_subst(pat, setmetatable({}, {__index = index}))
      else
         return apply_subst(pat, repl)
      end
   end,

   repl_suggest = function(self, args)
      return { title = string.format("%s:%s", self.chrome_name, self.name) }
   end,

   on_first_visual = function(self, args)
      for name, fun in pairs(self.to_js or {}) do
         args.view:register_function(name, fun(self, name))
      end
   end,

   repl = function() error([[Thou shalt not use the base repl list.
`repl_list_suggest` for some suggestions, like title]]) end,
}
