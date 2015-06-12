local db = require "listox.tox_db"
return setmetatable({ db = db }, require "listox.tox_history.ToxHistory")
