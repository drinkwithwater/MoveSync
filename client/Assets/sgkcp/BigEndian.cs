using System;

namespace SG.Network.skynet
{
    public static class BigEndian
    {
        public static void encode16u(byte[] p, int offset, UInt16 w)
        {
            p[1 + offset] = (byte)(w >> 0);
            p[0 + offset] = (byte)(w >> 8);
        }
        public static UInt16 decode16u(byte[] p, int offset)
        {
            UInt16 result = 0;
            result |= (UInt16)(p[0 + offset] << 8);
            result |= (UInt16)p[1 + offset];
            return result;
        }
        public static void encode32u(byte[] p, int offset, UInt32 l)
        {
            p[0 + offset] = (byte)(l >> 24);
            p[1 + offset] = (byte)(l >> 16);
            p[2 + offset] = (byte)(l >> 8);
            p[3 + offset] = (byte)(l >> 0);
        }
        public static UInt32 decode32u(byte[] p, int offset)
        {
            UInt32 result = 0;
            result |= (UInt32)(p[0 + offset] << 24);
            result |= (UInt32)(p[1 + offset] << 16);
            result |= (UInt32)(p[2 + offset] << 8);
            result |= (UInt32)p[3 + offset];
            return result;
        }
    }
}