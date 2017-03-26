-- @author Chen Ze
local skynet = require "skynet"
local socket = require "socket"
local KcpBindConnection = require "kcpBindConnection"
local UdpMessage = require "UdpMessage"
local queue = require "skynet.queue"
require "const"


local CMD = {}
local UDP_CMD = {}

local TOKEN_RANGE_MIN = 0x10000000
local TOKEN_RANGE_MAX = 0x7fffffff

local MIN_PACKET_LEN = 12 -- length by bytes, drop smaller udp packet

local mUDPSocket -- udp server socket

local mFdToConn = {}  -- tcpfd -> connection
local function get(vDict, vFd)
	return vDict[vFd]
end
local function set(vDict, vFd, vConn)
	vDict[vFd] = vConn
end

local mDictSyn = queue()

local udpFdCounter = 1
local genFd=function()
	udpFdCounter = udpFdCounter+1
	if udpFdCounter==0 then
		udpFdCounter = udpFdCounter+1
	end
	return udpFdCounter
end


skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
}


-- register in skynet/lualib/socket.lua
local function udpdispatch(vStr, vFrom)
	print(vStr, vFrom)
end

function CMD.forward(vFd)
	-- skynet.error("forward")
end

function CMD.open(conf)
	local address = conf.address or "0.0.0.0"
	local port = assert(conf.port)
	mUDPSocket = socket.udp(udpdispatch, address, port)
	--[[skynet.fork(function()
		while(true) do
			mDictSyn(function()
				local nRemoveKey={}
				for nFd, nConn in pairs(mFdToConn) do
					local nTime=skynet.now()
					if nConn:onUpdateClose(nTime) then
						nRemoveKey[nFd]=true
					end
				end
				for nFd, temp in pairs(nRemoveKey) do
					 mFdToConn[nFd]=nil
				end
			end)
			skynet.sleep(100)
		end
	end)]]
end

function CMD.exit()
	if mUDPSocket then
		socket.close(mUDPSocket)
		mUDPSocket = nil
	end
end


function UDP_CMD.open(vFd, vToken, vFrom)
	local nConn = KcpBindConnection.new(mUDPSocket, skynet.self())
	nConn:onOpen(vFd, vToken, vFrom)
	mDictSyn(set, mFdToConn, vFd, nConn)
	return nConn
end

function UDP_CMD.ping(vFd)
	local nConn = mDictSyn(get, mFdToConn, vFd)
	if nConn then
		nConn:onPing()
	end
end

function UDP_CMD.send(vFd, vData)
	local nConn = mDictSyn(get, mFdToConn, vFd)
	if nConn then
		nConn:doSend(vData)
	else
		skynet.error("udp connection not found for fd=", vFd)
	end
end

-- called when agent close itself.
function CMD.close(vFd)
	UDP_CMD.close(vFd)
end

function UDP_CMD.close(vFd)
	local nConn = mDictSyn(get, mFdToConn, vFd)
	if nConn then
		nConn:doClose()
		mDictSyn(set, mFdToConn, vFd, nil)
	end
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		if cmd=="udp" or cmd=="UDP" or cmd=="kcp" or cmd=="KCP" then
			local f = assert(UDP_CMD[subcmd])
			f(...)
			-- udp cmd not need ret
			-- skynet.ret(skynet.pack(f(...)))
		else
			local f = assert(CMD[cmd])
			skynet.ret(skynet.pack(f(subcmd, ...)))
		end
	end)
end)
