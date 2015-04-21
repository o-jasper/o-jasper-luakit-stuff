-- Jasper den Ouden, placed in public domain.

require "socket"

-- microsecond and other time.
return {
   raw = function() return socket.gettime() end,
   ms = function() return math.floor(1000*socket.gettime()) end,
   s = function()  return math.floor(socket.gettime()) end,
}
