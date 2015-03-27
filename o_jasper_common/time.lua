require "socket"

-- microsecond and other time.

function cur_time() return socket.gettime() end
function cur_time_ms() return math.floor(1000*socket.gettime()) end
function cur_time_s()  return math.floor(socket.gettime()) end
