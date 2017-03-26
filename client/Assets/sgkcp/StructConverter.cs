using System;
using System.Linq;
using System.Collections.Generic;

namespace SG.Network.skynet
{
    public static class StructConverter
    {
        #region Unpack
        // TODO: find a better way!
        private static byte[] GetAndFlipFromBuffer(byte[] inputBytes, int startPosition, int length)
        {
            byte[] theseBytes = new byte[length];
            for (int i = 0; i < length; i++)
            {
                theseBytes[i] = inputBytes[startPosition + (length - 1 - i)];
            }
            return theseBytes;
        }

        public static void Unpack(byte[] bytes, out int item1, bool LittleEndian = true)
        {
            bool endianFlip = (LittleEndian != BitConverter.IsLittleEndian);

            if (endianFlip)
            {
                item1 = BitConverter.ToInt32(GetAndFlipFromBuffer(bytes, 0, 4), 0);
            }
            else
            {
                item1 = BitConverter.ToInt32(bytes, 0);
            }
        }
        public static void Unpack(byte[] bytes, out int item1, out int item2, bool LittleEndian = true)
        {
            bool endianFlip = (LittleEndian != BitConverter.IsLittleEndian);

            if (endianFlip)
            {
                item1 = BitConverter.ToInt32(GetAndFlipFromBuffer(bytes, 0, 4), 0);
                item2 = BitConverter.ToInt32(GetAndFlipFromBuffer(bytes, 4, 4), 0);
            }
            else
            {
                item1 = BitConverter.ToInt32(bytes, 0);
                item2 = BitConverter.ToInt32(bytes, 4);
            }
        }
        public static void Unpack(byte[] bytes, out int item1, out int item2, out int item3, bool LittleEndian = true)
        {
            bool endianFlip = (LittleEndian != BitConverter.IsLittleEndian);

            if (endianFlip)
            {
                item1 = BitConverter.ToInt32(GetAndFlipFromBuffer(bytes, 0, 4), 0);
                item2 = BitConverter.ToInt32(GetAndFlipFromBuffer(bytes, 4, 4), 0);
                item3 = BitConverter.ToInt32(GetAndFlipFromBuffer(bytes, 8, 4), 0);
            }
            else
            {
                item1 = BitConverter.ToInt32(bytes, 0);
                item2 = BitConverter.ToInt32(bytes, 4);
                item3 = BitConverter.ToInt32(bytes, 8);
            }
        }
        #endregion

        #region Pack
        static List<byte> outputBytes = new List<byte>();
        private static void AddToBuffer(byte[] inputBytes, List<byte> outputBytes, bool flip)
        {
            for(int i = 0; i < inputBytes.Length; i++)
            {
                int index = flip ? (inputBytes.Length - 1 - i) : i;
                outputBytes.Add(inputBytes[index]);
            }
        }

        public static byte[] Pack(int item1, bool LittleEndian = true)
        {
            outputBytes.Clear();
            
            bool endianFlip = (LittleEndian != BitConverter.IsLittleEndian);

            AddToBuffer(BitConverter.GetBytes(item1), outputBytes, endianFlip);

            return outputBytes.ToArray();
        }
        public static byte[] Pack(int item1, int item2, bool LittleEndian = true)
        {
            outputBytes.Clear();

            bool endianFlip = (LittleEndian != BitConverter.IsLittleEndian);

            AddToBuffer(BitConverter.GetBytes(item1), outputBytes, endianFlip);
            AddToBuffer(BitConverter.GetBytes(item2), outputBytes, endianFlip);

            return outputBytes.ToArray();
        }
        public static byte[] Pack(int item1, int item2, int item3, bool LittleEndian = true)
        {
            outputBytes.Clear();

            bool endianFlip = (LittleEndian != BitConverter.IsLittleEndian);

            AddToBuffer(BitConverter.GetBytes(item1), outputBytes, endianFlip);
            AddToBuffer(BitConverter.GetBytes(item2), outputBytes, endianFlip);
            AddToBuffer(BitConverter.GetBytes(item3), outputBytes, endianFlip);

            return outputBytes.ToArray();
        }
        #endregion
    }
}