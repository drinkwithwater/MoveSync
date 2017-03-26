local skynet = require "skynet"
local snax = require "snax"

skynet.start(function()
	local udpserver = skynet.newservice("moveUdpServer")
	skynet.call(udpserver, "lua", "open", {
		port = 8888,
	})
	skynet.exit()
end)
