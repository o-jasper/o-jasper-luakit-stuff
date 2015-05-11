local tox = require "init"

print(tox.version_major(), tox.version_minor(), tox.version_minor)

--local opts = tox.options_new()

--print(tox.new(opts, nil))

local raw = require "raw"
print(raw.tox_new(nil, nil, 0, nil))
