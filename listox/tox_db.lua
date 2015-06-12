local ret

if not ret then
   local capi = { sqlite3 = sqlite3 }
   local file = os.getenv("HOME") .. "/.config/tox/tox.db"
   ret = capi.sqlite3{ filename = file }
end

return ret
