using System;
using UnityEngine;

namespace SG.Network.skynet
{
    public class MessageCounter
    {
        private int sendByteCounter = 0;
        private int sendPacketCounter = 0;
        private int receiveByteCounter = 0;
        private int receivePacketCounter = 0;
        private int lastSendByteCounter = 0;
        private int lastReceiveByteCounter = 0;
        private UInt32 lastTime = TimeHelper.GetMilliseconds();
        public void SendPacketCount(int length)
        {
            sendPacketCounter += 1;
            sendByteCounter += length;
        }
        public void RecvPacketCount(int length)
        {
            receivePacketCounter += 1;
            receiveByteCounter += length;
        }
        public void Show(string tag)
        {
            UInt32 curTime = TimeHelper.GetMilliseconds();
            int timeInterval = (int)(curTime - lastTime) / 1000;
            lastTime = curTime;
            int sendByteInterval = sendByteCounter - lastSendByteCounter;
            lastSendByteCounter = sendByteCounter;
            int receiveByteInterval = receiveByteCounter - lastReceiveByteCounter;
            lastReceiveByteCounter = receiveByteCounter;
            const float _1MB = 1024 * 1024;
            const float _1KB = 1024;
            Debug.Log(string.Format("[{0}]Total Send: packets {1}, bytes {2} ({3:F})MB", tag, sendPacketCounter, sendByteCounter, sendByteCounter / _1MB));
            Debug.Log(string.Format("[{0}]Total Receive: packets {1}, bytes {2} ({3:F})MB", tag, receivePacketCounter, receiveByteCounter, receiveByteCounter / _1MB));
            Debug.Log(string.Format("[{0}]Current Speed: up ({1:F})KB/s, down ({2:F})KB/s", tag, (sendByteInterval / _1KB) / timeInterval, (receiveByteInterval / _1KB) / timeInterval));
        }
    }
}