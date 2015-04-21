--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- NOTE not used at this point.
-- TODO probably remove.

local meta = log_metaindex_direct

meta.update_re_assess_list = function(self) function(upto_time)
      self.re_assess.list = self.db:exec([[SELECT * FROM msgs WHERE re_assess_time < ?
SORT BY re_assess_time]], upto_time)
end end

meta.msg_re_assess = function(self) function(msg)
   local re_assess = self.re_assess
   local pre = {id= msg.id, claimtime=msg.claimtime, from=msg.from, kind=msg.kind)
   user.assess(msg, logger[msg.kind].assess(msg))
      
   msg_sanity(msg)
   
   for k, v in pairs(pre) do -- Some things may not change.
      if msg[k] ~= v then
         bad(msg, "May not change" .. k, pre)
         msg[k] = v
      end
   end

   if msg.update_time < cur_time.s() + re_assess.wait then 
      bad(msg, "Update time at least seconds in the future.",
          {min_update_wait=re_assess.min_wait})
      msg.update_time = cur_time.s() + re_assess.min_wait
   end
end end

meta.re_assess_1 = function(self) function(upto_time)
   local re_assess = self.re_assess
   -- Repopulate if empty.
   if #re_assess.list == 0 then update_re_assess_list(upto_time) end
   if #re_assess.list == 0 then return 0 end  -- No new ones, apparently.
   
   local msg = self.msg_re_assess(re_assess.list[0])
   if msg.keep then
      self.update_entirely_by(msg)
   else  -- Get rid of it.
      self.delete(msg.id)
   end
   -- This one is done.
   table.remove(re_assess.list, 1)
end end

meta.work = function(self) function(for_time)
   self.re_assess_1(cur_time.s() + self.re_assess.forward)
end end
