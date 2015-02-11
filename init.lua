--  Copyright (C) 12-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- Uses/searches `pass` for passwords for domains,
-- and searches in html tags for login forms.

local lousy = require("lousy")

local config = globals.search_login or {}

local executable = config.executable or "/usr/bin/pass"
local pass_args  = config.pass_args or ""
-- Force default accounts to use. Otherwise the first one of `pass`.
local account_default = config.account_default or {}
local pass_pre_domain = config.pass_pre_domain or ""

-- Call pass with this arg string
function pass_call(args)
   return executable .. ' ' .. pass_args .. args
end

local function say(w, what, more)
   w:set_prompt(string.format("[search_login] -- %s%s", what, more or ""))
end

local function str_bool(bool) if bool then return "true" else return "false" end end

local js = lousy.load_asset("search_login/enter_pw.js") or "alert(\"JS of search_login not found\"); 0xDEADBEEF;"

-- TODO Would be handy to have this as util/common.
local function domain_of_uri(uri) return string.lower(lousy.uri.parse(uri).host) end
local function default_true(x) if x == nil then return true else return x end end

function figure_account(domain)
   local exit, stdout, stderr = luakit.spawn_sync(pass_call("ls " .. domain));
   if exit ~= 0 then return nil end 

   local list = lousy.util.string.split(stdout, "\n")
   if list[1] ~= domain then print("Didnt start with domain? ", list[1]) end
   if #list < 2 then print("Dont have any logins") return nil end
   return string.sub(list[2], 11)
end

function search_login(w, account, seek_form, fill_user_form)
   seek_form      = default_true(seek_form)
   fill_user_form = default_true(fill_user_form)
   
   local domain = domain_of_uri(w.view.uri)
   if not account then  --If account not pre-given, use first in pass.
      account = account_default[domain] or figure_account(pass_pre_domain .. domain)
      if not account then
         return say(w, "Cant find account for", pass_pre_domain .. domain)
      end
   end

   local pw_of = pass_pre_domain .. domain .. "/" .. account
   local exit, stdout_passwd, stderr = luakit.spawn_sync(pass_call("show " .. pw_of))
   if exit ~= 0 then
      say(w, "Program failed, couldnt get password")
   end
   local result = w.view:eval_js(string.gsub(js, "{%%(%w+)}",
                                             {seekForm=str_bool(seek_form),
                                              fillUserForm=str_bool(fill_user_form),
                                              account=account,
                                              passwd=stdout_passwd:gsub("\n", "")}),
                                 {no_return=false})
   
   if type(result) ~= "string" then
      return say(w, "JS returns wrong.. ", result)
   elseif result == "false" then
      return say(w, "Didnt seem to work: ",  pw_of)
   else
      return say(w, "worked, right? ", pw_of)
   end
end

-- A provided command. You might want something more handy, like :login or shorter.
local cmd, any = lousy.bind.cmd, lousy.bind.any

add_cmds({cmd("search_login", "Searches for password and way to login, and.. logs in",
              search_login)})
