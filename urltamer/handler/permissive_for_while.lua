return function(for_time, scratch)
   -- For duration of run.
   if for_time == 0 then return require "urltamer.handler.permissive" end

   local to_time = os.time() + for_time
   return function(info, result, also_allow)
      if os.time() < to_time then
         result.allow = true
      else -- Scratch the result.
         scratch()
      end
   end
end
