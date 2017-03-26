-- @author Chen Ze
require "functions"
require "const"
local LKcp = require "lkcp"
local skynet = require "skynet"
local socket = require "socket"
local queue = require "skynet.queue"
local UdpMessage = require "UdpMessage"

local KcpBindConnection = class()

local STATE_SYN_RCVD = 1
local STATE_ESTABLISHED = 2
local STATE_CLOSE = 3

local KCP_TIME_COE = 10 -- convert skynet.now() to kcp time (xxx ms)
local PING_TIMEOUT = 2000 -- 10s
local CONN_TIMEOUT = 500 -- 5s


local DEFAULT_MINRTO = 30
local DEFAULT_MTU = 1000

local function udp_address(vFrom)
	local vIP,vPort = socket.udp_address(vFrom)
	local nAddr = vIP..":"..vPort
	return nAddr
end

-- [public]
function KcpBindConnection:ctor(vUDPSocket, vUDPServer)
	self.mUDPSocket	=	vUDPSocket
	self.mUDPServer =	vUDPServer

	self.mFd		=	nil			-- the first tcp bind with, used as a udp fd
	self.mToken		=	nil			-- authorized token, also used as conv segments in kcp
	self.mFrom		=	nil			-- client's udp address

	self.mAgent		=	nil			-- agent service from watchdog

	self.mSyn		=	queue()		-- CriticalSection created by skynet.queue()
	self.mState		=	nil			-- wait/established/close

	self.mBuffer	=	nil			-- reading buffer in kcp
	self.mKcp		=	nil			-- kcp instance
	self.mPingTime	=	skynet.now()-- last ping time
	self.mStartTime	=	skynet.now()-- start time
end

-- [public], called after new()
function KcpBindConnection:onOpen(vFd, vToken, vFrom)
	self.mFd		=	vFd
	self.mToken		=	vToken
	self.mFrom		=	vFrom
	self.mState		=	STATE_SYN_RCVD
	self:doUdpSend(UdpMessage.s2cSyn(vFd, vToken))
end



local function ar2xy(angle,radio)
	local piAngle=angle/180*math.pi
	return radio*math.cos(piAngle), radio*math.sin(piAngle)
end
function KcpBindConnection:onMoveOper(dir)
	self.moveOper=dir
	if not self.startMove then
		self.startMove=true
		self.lastUpdateTime=skynet.time()
		self.frame=0
		self.dir=dir
		self.pos={
			x=0,
			y=0
		}
	end
end
-- for NetworkMoveProject
function KcpBindConnection:doMoveOper()
	local dir=self.moveOper
	if not dir then
		return
	else
		self.dir=dir
		self.moveOper=nil
	end
	--[[
	local dt=(skynet.time()-self.lastUpdateTime)
	local dx,dy=ar2xy(self.dir.angle, dt*self.dir.radio)
	self.pos.x = self.pos.x + dx
	self.pos.y = self.pos.y + dy
	self.dir=dir
	local sendMsg=sendFormat:format(self.frame+dt, self.pos.x, self.pos.y, self.dir.angle, self.dir.radio)
	self:doSend(string.pack(">s2",sendMsg))]]
end

sendFormat="%f %f %f %d %d" -- frame pos.x pos.y dir.x dir.y
-- for NetworkMoveProject
function KcpBindConnection:onUpdateFrame()
	self.lastUpdateTime=skynet.time()
	if self.startMove then
		self.frame = self.frame + 1
		local dx,dy=ar2xy(self.dir.angle, self.dir.radio)
		self.pos.x = self.pos.x + dx
		self.pos.y = self.pos.y + dy
		self:doMoveOper()
		local sendMsg=sendFormat:format(self.frame, self.pos.x, self.pos.y, self.dir.angle, self.dir.radio)
		self:doSend(string.pack(">s2",sendMsg))
	end
end

-- [public], update for send
function KcpBindConnection:onUpdateClose(vTime)
	local nCurTime = vTime or skynet.now()
	if self.mState == STATE_SYN_RCVD then
		local nConnTime = nCurTime-self.mStartTime
		if nConnTime>0.3 and nConnTime<CONN_TIMEOUT then
			-- send syn again
			self:doUdpSend(UdpMessage.s2cSyn(self.mFd, self.mToken))
			return false
		elseif nConnTime>=CONN_TIMEOUT then
			-- close
			local nAddr = udp_address(self.mFrom)
			skynet.error("kcp client ", nAddr, " connect-timeout")
			return true
		end
	elseif self.mState == STATE_ESTABLISHED then
		if nCurTime-self.mPingTime>PING_TIMEOUT then
			local nAddr = udp_address(self.mFrom)
			--skynet.error("kcp client from ", nAddr, " ping-timeout")
			--self:doClose()
			--return true
			return false
		else
			return false
		end
	end
end

-- [public], ping
function KcpBindConnection:onPing()
	self.mPingTime = skynet.now()
end

-- [public], when udpserver recv message, vParam1 is token when kcp, vParam1&vParam2 are oper&token when udp
function KcpBindConnection:onMessage(vParam1, vParam2, vStr, vFrom)
	if vParam1>=0 and vParam1<=100 then
		self:onUdpOper(vParam1, vParam2, vStr, vFrom)
	else
		self:onInput(vParam1, vStr:sub(5), vFrom)
	end
end

-- [private], udp oper except kcp message
function KcpBindConnection:onUdpOper(vOper, vToken, vStr, vFrom)
	if self.mState == STATE_SYN_RCVD then
		if vOper == UdpMessage.C2S_ACK then -- client handshake ACK
			local _a, _b, _c, nMinrto, nMtu = UdpMessage.serverUnpack(vStr)
			if self.mToken == vToken and self.mFrom == vFrom then
				self:operEstablished(nMinrto, nMtu, vFrom)
				self:doUdpSend(UdpMessage.s2cAck(self.mFd, self.mToken))
			end
		end
	elseif self.mState == STATE_ESTABLISHED then
		if vOper == UdpMessage.C2S_ACK then -- client handshake ACK
			if self.mToken == vToken and self.mFrom == vFrom then
				self:doUdpSend(UdpMessage.s2cAck(self.mFd, self.mToken))
			end
		end
	end
end

local function kcpUpdateCheckRecv(vKcp)
	local nCurTime = skynet.now()
	local nKcpTime = nCurTime * KCP_TIME_COE
	vKcp:lkcp_update(nKcpTime)
	local nNextTime = math.ceil(vKcp:lkcp_check(nKcpTime) / KCP_TIME_COE)
	return nNextTime-nCurTime, vKcp:lkcp_recv()
end

-- [private], kcp input
function KcpBindConnection:onInput(vToken, vPayload, vFrom)
	if self.mToken ~= vToken then
		local nAddr = udp_address(vFrom)
		skynet.error("udp:", nAddr, " send with unexcept token")
		self:doUdpSend(UdpMessage.s2cRst())
	elseif self.mState == STATE_ESTABLISHED then
		self.mFrom = vFrom
		local nKcp = self.mKcp
		local _, nLen, nData = self.mSyn(function()
			nKcp:lkcp_input(vPayload)
			--nLen, nData = nKcp:lkcp_recv()
			--nKcp:lkcp_flush()
			--return nLen, nData
			return kcpUpdateCheckRecv(nKcp)
		end)
		if (nLen>0) then
			local nGet, nInnerPayload = self:unpackMessage(nData)
			if nGet then
				self:dispatchMessage(nInnerPayload)
			end
		end
	end
end


-- [private], called when udp client come
function KcpBindConnection:operEstablished(vMinrto, vMtu, vFrom)
	vMinrto = vMinrto or DEFAULT_MINRTO
	vMtu = vMtu or DEFAULT_MTU
	if self.mState==STATE_SYN_RCVD then
		local nKcp = LKcp.lkcp_create(self.mToken,function(buf)
			self:doUdpSend(buf)
		end)
		nKcp:lkcp_nodelay(1,20,2,1)
		nKcp:lkcp_wndsize(128,128)
		if vMinrto>=20 and vMinrto<=50 then
			nKcp:lkcp_setminrto(vMinrto)
		else
			nKcp:lkcp_setminrto(DEFAULT_MINRTO)
		end
		if vMtu>=900 and vMtu<=1400 then
			nKcp:lkcp_setmtu(vMtu)
		else
			nKcp:lkcp_setmtu(DEFAULT_MTU)
		end
		self.mKcp=nKcp

		-- local nAgentService = skynet.newservice("agent")
		-- self.mAgent = nAgentService
		-- skynet.call(nAgentService, "lua", "start", { udpserver=self.mUDPServer, client = self.mFd,
		--									watchdog=self.mUDPServer, kcptoken=self.mToken, use_kcp=true})

		self.mState = STATE_ESTABLISHED
		self:scheduleKcp()
		local nAddr = udp_address(vFrom)
		skynet.error("udp:", nAddr, " connected ", "token,minrto,mtu=", self.mToken, nMinrto, nMtu)
	end
end



-- [public], send by udp
function KcpBindConnection:doUdpSend(vBuf)
	socket.sendto(self.mUDPSocket, self.mFrom, vBuf)
end

-- [public], send by kcp
function KcpBindConnection:doSend(vData)
	if self.mState == STATE_ESTABLISHED then
		local nKcp = self.mKcp
		self.mSyn(function()
			nKcp:lkcp_send(vData)
			local nKcpTime = skynet.now() * KCP_TIME_COE
			nKcp:lkcp_update(nKcpTime)
			--nKcp:lkcp_flush()
		end)
	else
		skynet.error("udp connection not established for fd=", self.mFd, self.mState)
	end
end

-- [public]
function KcpBindConnection:doClose()
	self.mState=STATE_CLOSE
	if self.mAgent then
		skynet.send(self.mAgent, "lua", "disconnect")
	end
end

-- [private], the functions below are called in update schedule thread
function KcpBindConnection:scheduleKcp()
	local nNextInterval, nLen, nData = self.mSyn(kcpUpdateCheckRecv, self.mKcp)
	if nLen>0 then
		local nGet, nInnerPayload = self:unpackMessage(nData)
		if nGet then
			self:dispatchMessage(nInnerPayload)
		end
	end
	skynet.timeout(nNextInterval, function()
		if(self.mState == STATE_ESTABLISHED) then
			self:scheduleKcp()
		elseif(self.mState == STATE_CLOSE) then
			self.mKcp=nil
			self.mSyn=nil
		-- elseif because first schedule called after established, STATE_SYN_RCVD is impossible
		end
	end)
end

-- Because lua-kcp's api use string(skynet use userdata) as packet payload,
-- I have to split packets in a stupid and slow way..
-- Skynet use c function: netpack.filter, detail in skynet/lualib/snax/gateserver.lua
function KcpBindConnection:unpackMessage(vMsg)
	local nBuffer = (self.mBuffer or "")..vMsg
	if #nBuffer<2 then
		self.mBuffer = nBuffer
		return false
	else
		-- skynet use 2 byte to indicate the packat size
		local nLen = string.unpack(">H", nBuffer)
		if #nBuffer>=nLen+2 then
			local nRet = nBuffer:sub(3,nLen+2)
			local nLeft = nBuffer:sub(nLen+3)
			self.mBuffer = nLeft
			return true, nRet
		else
			self.mBuffer = nBuffer
			return false
		end
	end
end


-- dispatch message after splitting and combining,
-- message will be parsed with sproto by agent
function KcpBindConnection:dispatchMessage(vMsg)
	local agent = self.mAgent
	if agent then
		skynet.redirect(agent, self.mUDPServer, "client", 1, vMsg)
	else
		local angle=tonumber(vMsg)
		if angle>=0 then
			local speed=6
			self:onMoveOper({angle=angle,radio=speed})
		else
			local speed=0
			self:onMoveOper({angle=angle,radio=0})
		end
		print("receive:",vMsg,#vMsg)
		-- self:doSend(string.pack(">H",2)..vMsg)
		-- skynet.send(watchdog, "lua", "socket", "data", fd, netpack.tostring(msg, sz))
	end
end

return KcpBindConnection
