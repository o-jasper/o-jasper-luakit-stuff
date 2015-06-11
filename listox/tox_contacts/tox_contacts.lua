local ret

local capi = { sqlite3 = sqlite3 }

if not ret then
   local file = os.getenv("HOME") .. "/.config/tox/tox.db"
   print(file)
   local db = capi.sqlite3{ filename = file }
   ret = setmetatable({ db = db }, require "listox.tox_contacts.ToxContacts")
end

return ret
