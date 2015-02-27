--  Copyright (C) 17-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

urlcommands, urlfuncs = {}, {}

function add_urlcmds(tab)
   for _, el in pairs(tab) do urlcommands[el.name] = el end
end
function add_urlfuncs(tab)
   for _, el in pairs(tab) do urlfuncs[el.name] = el end
end

function urlfunc(name, desc, fun)
   if type(desc) == "function" then
      assert(fun == nil)
      return { name=name, fun=desc }
   end
   assert(type(fun) == "function")
   return {name=name, desc=desc, fun=fun}
end

urlcmd = urlfunc

add_urlcmds({
   urlcmd("require_mark", function(_, _, result, args)
      if not result.marks or not result.marks[args[2]] then return "no" end
   end),
   urlcmd("require_not_mark", function(_, _, result, _)
      if result.marks and result.marks[args[2]] then return "no" end
   end),

   urlcmd("block_late", "Block if time runs out.",
   function(_, info, _, args)
      assert(#args == 2 and args[1] == ":block_late" and type(args[2]) == "number",
             string.format("%d %s %s %s %s", #args, args[1], args[2], args[3], type(args[2])))
      if info.dt and info.dt > args[2] then
         return "no"         
      end
   end),

   urlcmd("uri_maxlen", function(_, info, _, args)
      if #(info.uri) > args[2] then
         return "no"
      end
   end),

   urlcmd("set_result", function(_, _, result, args)
      result[args[2]] = args[3]
   end),

   urlcmd("yes_dominate", function(_, _, result, _)
      if result.yes then result.no = false end
   end),

   urlcmd("own_domain", function(_, info, _, _)
      if info.from_domain ~= "no_vuri" and info.from_domain ~= info.domain then
         return "no"
      end
   end),

   urlcmd("allow_userevent", function(_, info, _, _)
     if info.by_userevent then return "yes" end
   end),

   urlcmd("about_blank_redirect", function(_, info, result, args)
     if info.uri == "about:blank" then
        result.redirect = (args[2] == "vuri") and info.vuri or args[2]
        if args[3] == "yes" then return "yes" end
     end
   end),

   urlcmd("wrong", "Not a url command", function(_, _, _, args)
      print("Not an url command", table.concat(args))
   end),
})

add_urlfuncs({
   urlfunc("allow", function(_, _, _) return "yes" end),
   urlfunc("disallow", function(_, _, _, _) return "no" end),
   
   urlfunc("mark", "Give marks indicated in `way.marks`", function(way, _, result)
      result.marks = result.marks or {}
      for _, m in ensure_pairs(way.marks) do
         result.marks[m] = true
      end
   end),
   urlcmd("allow_statusses", "Allow if one of `way.statusses`",
   function(way, info, _)
      for i, el in ensure_pairs(way.statusses) do
         if i ~= 1 and el == info.status then return end
      end
      return "no"
   end),
})
