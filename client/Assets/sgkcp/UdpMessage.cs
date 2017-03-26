using System;
using UnityEngine;

namespace SG.Network.skynet
{
#if SLUA
    [SLua.CustomLuaClass]
#endif
    public static class UdpMessage
    {
        public const int S2C_RST = 0;
        public const int C2S_SYN = 1;
        public const int C2S_ACK = 2;
        public const int S2C_SYN = 3;
        public const int S2C_ACK = 4;
        public const int C2S_RESET = 5;
        public const int C2S_PING = 6;
        public const int S2C_PING_ACK = 7;

        public struct KcpStruct
        {
            public int fd;
            public int oper;
            public int token;

            public KcpStruct(int oper)
            {
                this.oper = oper;
                this.fd = 0;
                this.token = 0;
            }
        };
        
        private const String HELLO_STR = "helloworld";
        public static byte[] c2sSyn()
        {
            byte[] nByte = StructConverter.Pack(0);

            int len = HELLO_STR.Length + nByte.Length;

            byte[] bytes = new byte[len];

            int offset = 0;
            Buffer.BlockCopy(nByte, 0, bytes, 0, nByte.Length);
            offset = offset + nByte.Length;

            byte[] cBytes = System.Text.Encoding.ASCII.GetBytes(HELLO_STR);
            Buffer.BlockCopy(cBytes, 0, bytes, offset, cBytes.Length);

            return bytes;
        }

        public static byte[] c2sAck(int fd, int token)
        {
            return StructConverter.Pack(fd, C2S_ACK, token);
        }
        /*
        public static byte[] c2sReset(int fd, int token)
        {
            return StructConverter.Pack(fd, C2S_RESET, token);
        }

        public static byte[] c2sPing(int fd, int token)
        {
            return StructConverter.Pack(fd, C2S_PING, token);
        }

        public static byte[] s2cSyn(int fd, int token)
        {
            return StructConverter.Pack(S2C_SYN, fd, token);
        }

        public static byte[] s2cAck(int fd, int token)
        {
            return StructConverter.Pack(S2C_ACK, fd, token);
        }

        public static byte[] s2cPingAck()
        {
            return StructConverter.Pack(S2C_PING_ACK);
        }

        public static byte[] s2cRst()
        {
            return StructConverter.Pack(S2C_RST);
        }
        
        public static object[] serverUnpack(byte[] vBytes)
        {
            object[] list = null;
            if (vBytes.Length == 12)
            {
                list = StructConverter.Unpack("<iii", vBytes);
            }
            else if (vBytes.Length == 16)
            {
                list = StructConverter.Unpack("<iiii", vBytes);
            }
            else if (vBytes.Length == 20)
            {
                list = StructConverter.Unpack("<iiiii", vBytes);
            }
            return list;
        }*/
        
        public static KcpStruct clientUnpack(byte[] vBytes)
        {
            int oper = 0;
            StructConverter.Unpack(vBytes, out oper);
            KcpStruct kcp = new KcpStruct(oper);
            switch(oper)
            {
                case S2C_ACK:
                case S2C_RST:
                    break;
                case S2C_SYN:
                    StructConverter.Unpack(vBytes, out kcp.oper, out kcp.fd, out kcp.token);
                    break;
                default:
                    Debug.LogErrorFormat("[UdpMessage] oper {0}", oper);
                    break;
            }
            return kcp;
        }
    }
}