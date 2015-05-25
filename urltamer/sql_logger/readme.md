# SQL logging
Logs how sites connect with SQL, and can show with listview.

Main forseen purpose is to be able to quickly produce patterns to (not)block.

However, it is basically a history browser, but views a bit messy right now
because *every* asset of a site registers. If all implied links can
eseasily be hidden, perhaps.

Perhaps needs a better way how it puts it into SQL. I.e. there is a uri in a
window-viewed-this entry and the other entries refer to that.
(as opposed to the entries as all separate.)

### TODO

* Make a tab going to a uri an entry, and other uris it obtains refer to it.
  + Main one also gets a `title`, keep track of number of visits.
  + Other uris get a `dt`.

* Make an SQL table for blocking preferences.
  Think nicest to select by domain and then directory bits optionally.
  
  + Allow definitions to be made from the SQL table.

* Time limits to keep things up to various levels.

* Keep stats on how much domains link to each other. 

  Note: blocking does reduce *apparent* linkage, loads can cause more loads.
