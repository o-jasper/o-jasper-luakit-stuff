#!/usr/bin/env lua
-- Lua 5.1+ base64 v3.0 (c) 2009 by Alex Kloss <alexthkloss@web.de>
-- licensed under the terms of the LGPL2

-- Modified by Jasper den Ouden

-- symlink that file from i.e. `/home/jasper/.lualibs/` or anything in package.path
local base64 = require "o_jasper_common.base64"

local func = 'enc'
for n,v in ipairs(arg) do
   if n > 0 then
			if v == "-h" then print "base64.lua [-e] [-d] text/data" break
			elseif v == "-e" then func = 'enc'
			elseif v == "-d" then func = 'dec'
      elseif v == "-f" then func = 'enc_file'
			else 
         print(base64[func](v)) 
      end
   end
end
