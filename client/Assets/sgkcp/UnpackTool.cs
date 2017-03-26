using System.Collections.Generic;
using System;

namespace SG.Network.skynet
{
    public class UnpackTool
    {
        private const int HEAD_SIZE = 2;
        private LinkedList<byte[]> mMessageList = new LinkedList<byte[]>();
        private byte[] mHead = new byte[HEAD_SIZE];
        private byte[] mBody = null;
        private int mHeadNeed = HEAD_SIZE;
        private int mBodyNeed = 0;
        private int mQueueSize = 4096;
        public UnpackTool(int vQueueSize)
        {
            mQueueSize = vQueueSize;
        }
        public void Clear()
        {
            lock (mMessageList)
            {
                mHeadNeed = HEAD_SIZE;
                mBodyNeed = 0;
            }
        }
        // Attention: popAll is held repeatly
        private List<byte[]> nList = new List<byte[]>();
        public List<byte[]> popAll()
        {
            nList.Clear();
            lock (mMessageList)
            {
                nList.AddRange(mMessageList);
                mMessageList.Clear();
            }
            return nList;
        }

        public void UnpackMessage(byte[] vBuffer, int vLen)
        {
            lock (mMessageList)
            {
                int nFrom = 0;
                int nTo = vLen;
                while (nTo > nFrom)
                {
                    if (mHeadNeed > 0)
                    {
                        nFrom = unpackHead(vBuffer, nFrom, nTo - nFrom);
                    }
                    else if (mBodyNeed > 0)
                    {
                        nFrom = unpackBody(vBuffer, nFrom, nTo - nFrom);
                    }
                }
            }
        }

        int unpackHead(byte[] vBuffer, int vFrom, int vBufferRemain)
        {
            int x = UnityEngine.Mathf.Min(mHeadNeed, vBufferRemain);
            Array.Copy(vBuffer, vFrom, mHead, HEAD_SIZE - mHeadNeed, x);
            vFrom += x;
            mHeadNeed -= x;
            if (mHeadNeed == 0)
                gainHead();
            return vFrom;
        }

        int unpackBody(byte[] vBuffer, int vFrom, int vBufferRemain)
        {
            int x = UnityEngine.Mathf.Min(mBodyNeed, vBufferRemain);
            Array.Copy(vBuffer, vFrom, mBody, mBody.Length - mBodyNeed, x);
            vFrom += x;
            mBodyNeed -= x;
            if (mBodyNeed == 0)
                gainBody();
            return vFrom;
        }

        void gainHead()
        {
            // TODO: a better way to avoid GC?
            mBodyNeed = BigEndian.decode16u(mHead, 0);
            mBody = new byte[mBodyNeed];
        }

        void gainBody()
        {
            mMessageList.AddLast(mBody);
            if (mMessageList.Count > mQueueSize)
            {
                mMessageList.RemoveFirst();
            }
            mBody = null;
            mHeadNeed = HEAD_SIZE;
        }
    }
}