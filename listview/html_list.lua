--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local Public = {}

-- If a class provided, makes it addable to tag data.
local function maybeclass(class) return class and " class=\"".. class .. "\"" or "" end

local html= {
   el    = [[<td{%elClass}>{%elContent}</td>]],
   frow  = [[<tr{%elClass}><td>{%elContent}</td></tr>]],
   row   = [[<tr{%elClass}>{%elContent}</tr>]],
   list  = [[<table{%tableClass}>{%tableContent}</table>]],
   table = [[<table{%tableClass}>{%topRow}{%tableContent}</table>]]
}

function Public.row(data, fun, row, row_class)
   fun = fun or function(_,v) return tostring(v) end
   local str = ""
   for k, v in pairs(data) do
      local repl = {elContent=fun(k, v),
                    elClass=maybeclass(row_class or html.row_class or "")}
      str = str .. string.gsub(row or html.row, "{%%(%w+)}", repl)
   end
   return str
end

function Public.list(data, fun, row_class, table_class)
   return string.gsub(html.table, "{%%(%w+)}",
                      {topRow="",
                       tableContent=Public.row(data, fun, html.row, row_class),
                       tableClass=maybeclass(table_class or html.table)})
end

function Public.table(data, fun, toprow, row_class, table_class, usefun)
   local usefun = usefun or function(k, v)
      return Public.row(v, fun, html.el, row_class)
   end
   return string.gsub(html.table, "{%%(%w+)}",
                      {topRow=toprow or "",
                       tableContent=Public.row(data, usefun, html.row, row_class),
                       tableClass=maybeclass(table_class or html.table)})
end

local isinteger = require("o_jasper_common.other").isinteger

-- TODO sort it.
function Public.keyval(data, fun, toprow, row_class, table_class, el)
   return Public.table(data,
                       function(k, v)
                          if isinteger(v) and v > 1e15 then
                             v = string.format("%d%d", math.floor(v/10e14), v%1e15)
                          end
                          return string.gsub(el or "{%k}: {%v}", "{%%(%w+)}",
                                             {k=tostring(k), v=tostring(v)})
                       end, toprow, row_class, table_class)
end

return Public
