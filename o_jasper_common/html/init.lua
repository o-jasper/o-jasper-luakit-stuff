local Public = {}

for _, file in pairs{"other", "time", "uri"} do
   for k,v in pairs(require("o_jasper_common.html." .. file)) do Public[k] = v end
end

return Public
