UdpMessage={
	S2C_RST=0,
	C2S_SYN=1,
	C2S_ACK=2,
	S2C_SYN=3,
	S2C_ACK=4,
	C2S_RESET=5,
	C2S_PING=6,
	S2C_PING_ACK=7,
}


local function newKcp(fd, oper, token, minrto, mtu)
	if minrto and mtu then
		return string.pack("<iiiii", fd, oper, token, minrto, mtu)
	elseif minrto then
		return string.pack("<iiii", fd, oper, token, minrto)
	else
		return string.pack("<iii", fd, oper, token)
	end
end

local HELLO_STR=string.pack("<i", 0).."helloworld"
function UdpMessage.c2sSyn()
	return HELLO_STR
end

function UdpMessage.c2sAck(fd, token, minrto, mtu)
	local oper = UdpMessage.C2S_ACK
	return newKcp(fd, oper, token, minrto, mtu)
end

function UdpMessage.c2sReset(fd, token, minrto, mtu)
	local oper = UdpMessage.C2S_RESET
	return newKcp(fd, oper, token, minrto, mtu)
end

function UdpMessage.c2sPing(fd, token)
	local oper = UdpMessage.C2S_PING
	return string.pack("<iii", fd, oper, token)
end

function UdpMessage.s2cSyn(fd, token)
	local oper = UdpMessage.S2C_SYN
	return string.pack("<iii", oper, fd, token)
end

function UdpMessage.s2cAck(fd, token)
	local oper = UdpMessage.S2C_ACK
	return string.pack("<iii", oper, fd, token)
end

function UdpMessage.s2cPingAck()
	local oper = UdpMessage.S2C_PING_ACK
	return string.pack("<iii", oper, 0, 0)
end

function UdpMessage.s2cRst()
	local oper = UdpMessage.S2C_RST
	return string.pack("<iii", oper, 0, 0)
end

function UdpMessage.serverUnpack(vStr)
	if #vStr==12 then
		local a, b, c = string.unpack("<iii", vStr)
		return a, b, c
	elseif #vStr==16 then
		local a, b, c, d = string.unpack("<iiii", vStr)
		return a, b, c, d
	elseif #vStr==20 then
		local a, b, c, d, e = string.unpack("<iiiii", vStr)
		return a, b, c, d, e
	end
end

function UdpMessage.clientUnpack(vStr)
	local oper = string.unpack("<i", vStr)
	if oper==UdpMessage.S2C_ACK then
		return {oper=oper}
	elseif oper==UdpMessage.S2C_SYN then
		local _, fd, token=string.unpack("<iii",vStr)
		return {oper=oper,fd=fd,token=token}
	elseif oper==UdpMessage.S2C_RST then
		return {oper=oper}
	else
		-- other things, not design...
		print("message exception")
		return nil
	end
end

return UdpMessage