local This = {}

function This:conf()       return globals.mirror or {} end
function This:mirror_dir()
   return self:conf().mirror_dir or (os.getenv("HOME") .. "/.luakit/mirror/")
end

function This:path(uri)
   if string.match(uri, "^http://") then uri = string.sub(uri, 8) end
   if string.match(uri, "^https://") then uri = string.sub(uri, 9) end
   return mirror_dir .. "/" .. uri
end

function This:clear_path(path)
   luakit.spawn("mkdir -p " .. path)
   luakit.spawn("rmdir" .. path) -- _Excessively_ lazy of me.
   return path
end

function This:mirror_uri(uri)
   return "file://" ..  self:path(uri)
end

return This
