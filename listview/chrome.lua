--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- Chrome page of all logs. User may do subselection.

config = (globals.listview or {})

local chrome = require("chrome")
local lousy = require("lousy")

require "listview.common"
require "listview.html_list"
require "listview.log"
require "listview.log_html"
--require "listview.work"

chrome_name = "listview"
chrome_uri = string.format("luakit://%s/", chrome_name)

log = new_log(capi.luakit.data_dir .. "/msgs.db")

local stylesheet = lousy.load_asset(string.format("%s/assets/style.css", chrome_name)) or ""
local js = lousy.load_asset(string.format("%s/assets/js.js", chrome_name)) or ""

local html_templates = {}
function get_template(name)
   if not html_templates[name] then
      html_templates[name] =
         lousy.load_asset(string.format("%s/assets/%s.html", chrome_name, name))
   end
   return html_templates[name] or 
      string.format("AINT GOT A TEMPLATE FOR THIS<br> expect in assets/%s", name)
end

local chrome_ran_cnt, search_cnt = 0, 0

-- How we end up searching.
local function total_query(search)
   local query = log.new_sql_help()
   if search ~= "" then query.searchtxt(search) end
   -- TODO other ones..
   return query
end

local current_search = ""

local function js_listupdate(list, as_msg)
   search_cnt = search_cnt + 1
   return { list=(as_msg and html_msg_list or html_list_keyval)(list),
            cnt=#list, search_cnt=search_cnt }
end

export_funcs={
   manual_test_enter = function(inp)
      local v= log.enter("manual", 
                         { claimtime=cur_time_s(),
                           re_assess_time = cur_time_s() + 120,
                           kind = "manual test", origin = "manual test",
                           data = "", data_uri = "",
                           uri = "", title = inp.title, desc = inp.desc,
                           keep = true,
                           tags = lousy.util.string.split(inp.tags, "[,; ]+")
                         })
   end,

   manual_sql = function(sql, as_msg)
      local list = log.db:exec(sql);
      if as_msg then list = map(list, log._msg) end
      return js_listupdate(list, as_msg)
   end,
   
   show_sql = function(inp)
      if inp.search ~= current_search then
         current_search = inp.search
         if not string.match(current_search, "^[ ,;:]+$") then
            return { sql_input = total_query(current_search).sql_code() }
         end
      end
      return {}
   end,

   update = function(search, as_msg)
      return js_listupdate(total_query(search).result(), as_msg)
   end,
}
local pages = {
   test = function(meta, dir_split, html)
      local list = log.new_sql_help().result()
      
      chrome_ran_cnt = chrome_ran_cnt + 1
      return string.gsub(html, "{%%(%w+)}",
                         { stylesheet = stylesheet, js=js,
                           title=string.format("%s:%s", chrome_name, "test"),
                           chromeRanCnt=chrome_ran_cnt,
                           cnt=#list,
                           list=html_msg_list(list)
                         })
   end,
}

chrome.add(chrome_name, function (view, meta)
    local dir_split = lousy.util.string.split(meta.path, "/")
    local use_name, use_uri = "log", string.format("luakit://%s/log", chrome_name)
    if pages[dir_split[1]] then
       use_name = dir_split[1]
       use_uri  = meta.uri
    end
    local html = (pages[use_name] or pages.test)(meta, dir_split, get_template(use_name))

    view:load_string(html, use_uri)
    
    function on_first_visual(v, status)
       -- Wait for new page to be created
       if status ~= "first-visual" then return end
       
       for name, func in pairs(export_funcs) do
          view:register_function(name, func)
       end
       
       -- Hack to run-once
       view:remove_signal("load-status", on_first_visual)
    end
    view:add_signal("load-status", on_first_visual)
end)
