local histpkg = require("history")
histpkg.init() -- History package uses `capi.luakit.idle_add(init)`
return histpkg.db
