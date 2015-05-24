
local config = (globals.urltamer or {}).sql_logger or {}

local UriRequests = require "urltamer.sql_logger.UriRequests"
local db = config.db or require "listview.acquire_db"

local ret
if not ret then
   -- Add table if needed.
   db:exec [[
CREATE TABLE IF NOT EXISTS uri_requests (
     id INTEGER PRIMARY KEY,
     time INTEGER,
  
     uri TEXT NOT NULL,
     vuri TEXT NOT NULL,

     domain TEXT NOT NULL,
     from_domain TEXT NOT NULL,

     result TEXT NOT NULL
   );
]]
   ret = setmetatable({db = db}, UriRequests)
end

return ret  -- TODO UriRequest has the `insert` method so is a logger.
