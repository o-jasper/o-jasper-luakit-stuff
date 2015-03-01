--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- If a class provided, makes it addable to tag data.
local function maybeclass(class) return class and " class=\"".. class .. "\"" or "" end

local html= {
   el    = [[<td{%elClass}>{%elContent}</td>]],
   frow  = [[<tr{%elClass}><td>{%elContent}</td></tr>]],
   row   = [[<tr{%elClass}>{%elContent}</tr>]],
   list  = [[<table{%tableClass}>{%tableContent}</table>]],
   table = [[<table{%tableClass}>{%topRow}{%tableContent}</table>]]
}

function html_row(data, fun, row, row_class)
   fun = fun or function(_,v) return tostring(v) end
   local str = ""
   for k, v in pairs(data) do
      local repl = {elContent=fun(k, v),
                    elClass=maybeclass(row_class or html.row_class or "")}
      str = str .. string.gsub(row or html.row, "{%%(%w+)}", repl)
   end
   return str
end

function html_list(data, fun, row_class, table_class)
   return string.gsub(html.table, "{%%(%w+)}",
                      {topRow="",
                       tableContent=html_row(data, fun, html.row, row_class),
                       tableClass=maybeclass(table_class or html.table)})
end

function html_table(data, fun, toprow, row_class, table_class, usefun)
   local usefun = usefun or function(k, v)
      return html_row(v, fun, html.el, row_class)
   end
   return string.gsub(html.table, "{%%(%w+)}",
                      {topRow=toprow or "",
                       tableContent=html_row(data, usefun, html.row, row_class),
                       tableClass=maybeclass(table_class or html.table)})
end

function html_list_keyval(data, fun, toprow, row_class, table_class, el)
   return html_table(data, function(k, v)
                               if isinteger(v) and v > 1e15 then
                                  v = string.format("%d%d", math.floor(v/10e14), v%1e15)
                               end
                               return string.gsub(el or "{%k}: {%v}", "{%%(%w+)}",
                                                  {k=tostring(k), v=tostring(v)})
                           end, toprow, row_class, table_class)
end
