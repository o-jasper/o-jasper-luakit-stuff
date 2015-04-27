
local Bookmarks = require "listview.more.Bookmarks"
local db = require "listview.more.acquire_db"

-- Add bookmark tables if needed.
db:exec [[
   CREATE TABLE IF NOT EXISTS bookmarks (
     id INTEGER PRIMARY KEY,
     created INTEGER,
  
     to_uri TEXT NOT NULL,
     title TEXT NOT NULL,
     desc TEXT NOT NULL,
  
     data_uri TEXT
   );

   CREATE TABLE IF NOT EXISTS bookmark_taggings (
     to_id INTEGER NOT NULL,
     tag TEXT NOT NULL
   );
]]

print("OM", Bookmarks.values.table_name)
return setmetatable({db = db}, Bookmarks)
