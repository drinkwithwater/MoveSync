using UnityEngine;
using System;
using System.Collections.Generic;
using System.Net.Sockets;
using System.Net;
using System.Threading;
using SG;

namespace SG.Network.skynet
{
    /** 
     * @author ChenZe
     */
    public class KcpSocket : MonoBehaviour
    {
        // ==========KcpSocket==========
        enum KCP_STATE
        {
            DOWN,
            SYN_SEND,
            ACK_SEND,
            UP,
        };

        //connect callback flag
        enum CONNECT_FLAG
        {
            NORMAL = 0,
            TIMEOUT = -1,
        }

        private int udpFd;
        private int token;
        private KCP_STATE kcpState = KCP_STATE.DOWN;

        // variable for handshake
        private uint startConnTime = 0;
        private int connRetryTime = 30;
        private int connTimeout = 5000; // 5s for default

        // variable for ping-keep
        private uint lastPingTime = 0;
        private int pingInterval = 3000;

        private System.Object recvCallback;
        private Action<int> connectCallback;

        public void Connect(int vTimeout, Action<int> nConnectCallback)
        {
            connectCallback = nConnectCallback;
            if (kcpState == KCP_STATE.UP)
            {
                //这里有些问题，lua中没有赋值，这里赋值一个没有的值
                connectCallback(-2);
            }
            else
            {
                StartUdpSocket();
                UdpSend(UdpMessage.c2sSyn());
                kcpState = KCP_STATE.SYN_SEND;

                //timeout timer set
                startConnTime = TimeHelper.GetMilliseconds();
                connTimeout = vTimeout;
                connRetryTime = 50;
            }
        }

        public bool IsConnected()
        {
            return kcpState == KCP_STATE.UP;
        }

        // callback, udp used for kcp handshake
        public void OnUdpMessage(byte[] vBytes)
        {
            UdpMessage.KcpStruct msg = UdpMessage.clientUnpack(vBytes);
            if (kcpState == KCP_STATE.SYN_SEND)
            {
                if (msg.oper == UdpMessage.S2C_SYN)
                {
                    udpFd = msg.fd;
                    token = msg.token;
                    StartKcp(udpFd, token, recvCallback);
                    kcpState = KCP_STATE.ACK_SEND;
                    UdpSend(UdpMessage.c2sAck(udpFd, token));
                }
            }
            else if (kcpState == KCP_STATE.ACK_SEND)
            {
                if (msg.oper == UdpMessage.S2C_ACK)
                {
                    kcpState = KCP_STATE.UP;
                    if (connectCallback != null)
                    {
                        connectCallback((int)CONNECT_FLAG.NORMAL);
                    }
                }
            }
        }

        public void OnUdpDown()
        {
            StartUdpSocket();
        }

        // expand update for handshake and ping-keep
        public void KcpExpandUpdate()
        {
            if (kcpState == KCP_STATE.SYN_SEND || kcpState == KCP_STATE.ACK_SEND)
            {
                int waitTime = (int)(TimeHelper.GetMilliseconds() - startConnTime);
                if (waitTime > connTimeout) {
                    connectCallback((int)CONNECT_FLAG.TIMEOUT);
                    kcpState = KCP_STATE.DOWN;
                    Close();
                } else if(waitTime > connRetryTime){
                    connRetryTime = connRetryTime * 2;
                    if (kcpState == KCP_STATE.SYN_SEND) {
                        UdpSend(UdpMessage.c2sSyn());
                    } else if (kcpState == KCP_STATE.ACK_SEND) {
                        UdpSend(UdpMessage.c2sAck(udpFd, token));
                    }
                }
            }
            else if (kcpState == KCP_STATE.UP)
            {
                uint curTime = TimeHelper.GetMilliseconds();
                if (curTime - lastPingTime > pingInterval) {
                    lastPingTime = curTime;
                }
            }
        }
        // ==========KcpSocket==========
        private MessageCounter mMessageCounter = new MessageCounter();

        private const int BUFFER_SIZE = 2048;
        private const int MAX_MSG_COUNT = 36000; // msg queue size limit implements in NetworkManager.txt...

        private const int MIN_PACKET_LEN = 12;
        private const int KCP_UPDATE_INTERVAL = 20;

        // message define
        public const int OPER_RANGE = 100;
        
        // udp items
        private Thread mRecvThread = null;
        private Socket mUdpSocket = null;
        private readonly object mSocketLock = new object();
        private bool downTriggerFlag = false;

        private IPEndPoint mSvrEndPoint;

        // kcp items
        private KCP mKcp = null;
        private readonly object mKcpLock = new object();
        private System.Object kcpRecvCall = null;

        private UnpackTool mUnpackTool = new UnpackTool(MAX_MSG_COUNT);
        private Queue<byte[]> mUdpMessageQueue = new Queue<byte[]>();

        private string mIP;
        private int mPort;

        private uint mFd;
        private uint mToken;

        private byte[] udpRecvBuffer = new byte[BUFFER_SIZE];
        private byte[] kcpRecvBuffer = new byte[BUFFER_SIZE];
        private byte[] sendBuffer = new byte[BUFFER_SIZE];

        // update
        private bool mNeedUpdateFlag = false;
        private UInt32 mNextUpdateTime = 0;

        private enum ModuleState { INIT, NORMAL, PAUSE, CLOSE, EXIT }
        private ModuleState mState = ModuleState.INIT;

        /**
         * set ip:port, create thread
         */
        public void Init(string ip, int port, System.Object nRecvCallback)
        {
            mIP = ip;
            mPort = port;

            recvCallback = nRecvCallback;

            mRecvThread = new Thread(new ThreadStart(ReceiveLoop));
            mRecvThread.IsBackground = true;
            mRecvThread.Start();
        }

        /*******************
         **** kcp funcs ****
         ******************/

        public void StartUdpSocket()
        {
            lock (mSocketLock)
            {
                mState = ModuleState.NORMAL;
                mUdpSocket = new Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp);
                mSvrEndPoint = new IPEndPoint(IPAddress.Parse(mIP), mPort);
                mUdpSocket.Connect(mSvrEndPoint);
            }
        }

        public void Close()
        {
            kcpState = KCP_STATE.DOWN;
            lock (mSocketLock)
            {
                mState = ModuleState.CLOSE;
                if (mUdpSocket != null)
                {
                    mUdpSocket.Close();
                }
            }
        }

        public void StartKcp(int vFd, int vToken, System.Object vKcpRecvCall)
        {
            mFd = (UInt32)vFd;
            mToken = (UInt32)vToken;
            kcpRecvCall = vKcpRecvCall;

            lock (mKcpLock)
            {
                mUnpackTool.Clear();
                // create kcp
                mKcp = new KCP(mToken, (byte[] buf, int size) =>
                {
                    LittleEndian.encode32u(sendBuffer, 0, mFd);
                    Array.Copy(buf, 0, sendBuffer, 4, size);
                    UdpSend(sendBuffer, size + 4);
                });

                // default setting
                mKcp.NoDelay(1, KCP_UPDATE_INTERVAL, 2, 1);
                //mKcp.SetMinrto(80);

            }
        }


        public void KcpNoDelay(int nodelay, int interval, int resend, int nc)
        {
            mKcp.NoDelay(nodelay, interval, resend, nc);
        }

        public void KcpSetMinrto(UInt32 rto)
        {
            mKcp.SetMinrto(rto);
        }

        public void KcpSend(byte[] buf)
        {
            lock (mKcpLock)
            {
                mKcp.Send(buf);
                //UInt32 nCurrent = TimeHelper.GetMilliseconds();
                //mKcp.Update(nCurrent);
                //mNextUpdateTime = mKcp.Check(nCurrent);
                mKcp.flush();
            }
        }

        public void UdpSend(byte[] buf, int len = -1)
        {
            if (len <= -1) len = buf.Length;
            Socket nSocket = mUdpSocket;
            try
            {
                nSocket.Send(buf, len, SocketFlags.None);
                mMessageCounter.SendPacketCount(len);
            }
            catch (Exception e)
            {
                Debug.LogError(string.Format("Kcp Socket send exception : {0}", e.Message));
                nSocket.Close();
                lock (mSocketLock)
                {
                    if (mState != ModuleState.CLOSE)
                    {
                        downTriggerFlag = true;
                        mState = ModuleState.CLOSE;
                    }
                }
            }
        }

        private void ReceiveAsync(IAsyncResult ar)
        {
            Socket nSocket = (Socket)ar.AsyncState;
            int nLen = nSocket.EndReceive(ar);
            if (nLen <= 0)
            {
                Debug.LogWarning("Receive length <=0;");
            }
            else
            {
                if (nLen >= MIN_PACKET_LEN)
                {
                    mMessageCounter.RecvPacketCount(nLen);
                    UInt32 nOperSession = 0;
                    KCP.ikcp_decode32u(udpRecvBuffer, 0, ref nOperSession);
                    byte[] nMsg = new byte[nLen];
                    Array.Copy(udpRecvBuffer, nMsg, nLen);
                    if (nOperSession < OPER_RANGE)
                    {
                        lock (mUdpMessageQueue)
                        {
                            mUdpMessageQueue.Enqueue(nMsg);
                        }
                    }
                    else
                    {
                        lock (mKcpLock)
                        {
                            if (mKcp != null)
                            {
                                mKcp.Input(nMsg);
                                //mNeedUpdateFlag = true;
                                mKcp.flush();
                                int nRecvLen = mKcp.Recv(kcpRecvBuffer);
                                if (nRecvLen > 0)
                                {
                                    mUnpackTool.UnpackMessage(kcpRecvBuffer, nRecvLen);
                                }
                                else if (nRecvLen == -3)
                                {
                                    Debug.LogError("recv buffer length not enough");
                                }
                            }
                        }
                    }
                }
            }
        }
        private void ReceiveLoop()
        {
            IAsyncResult nReceiveAsyncResult = null;
            while (true)
            {
                if (mState == ModuleState.EXIT)
                {
                    break;
                }
                else if (mState == ModuleState.CLOSE)
                {
                    Thread.Sleep(300);
                    continue;
                }
                else if (mState != ModuleState.NORMAL && mState != ModuleState.PAUSE)
                {
                    Thread.Sleep(100);
                    continue;
                }
                Socket nSocket;
                if (mUdpSocket == null)
                {
                    Thread.Sleep(100);
                }
                else if (nReceiveAsyncResult != null)
                {
                    bool nSuccess = nReceiveAsyncResult.AsyncWaitHandle.WaitOne(KCP_UPDATE_INTERVAL, true);
                    if (nSuccess)
                    {
                        lock (mSocketLock)
                        {
                            nSocket = mUdpSocket;
                        }
                        try
                        {
                            nReceiveAsyncResult = nSocket.BeginReceive(udpRecvBuffer, 0, BUFFER_SIZE, SocketFlags.None, new AsyncCallback(ReceiveAsync), nSocket);
                        }
                        catch (Exception e)
                        {
                            Debug.LogErrorFormat("Kcp Socket receive exception : {0}", e.Message);
                            nSocket.Close();
                            lock (mSocketLock)
                            {
                                if (mState != ModuleState.CLOSE)
                                {
                                    downTriggerFlag = true;
                                    mState = ModuleState.CLOSE;
                                }
                            }
                        }
                    }
                    lock (mKcpLock)
                    {
                        if (mKcp != null)
                        {
                            uint nCurrent = TimeHelper.GetMilliseconds();
                            if (mNeedUpdateFlag || nCurrent >= mNextUpdateTime)
                            {
                                mKcp.Update(nCurrent);
                                mNextUpdateTime = mKcp.Check(nCurrent);
                                mNeedUpdateFlag = false;
                            }
                            // do recv
                            int nLen = mKcp.Recv(kcpRecvBuffer);
                            if (nLen > 0)
                            {
                                mUnpackTool.UnpackMessage(kcpRecvBuffer, nLen);
                            }
                            else if (nLen == -3)
                            {
                                Debug.LogError("recv buffer length not enough");
                            }
                        }
                    }
                }
                else if (nReceiveAsyncResult == null)
                {
                    lock (mSocketLock)
                    {
                        nSocket = mUdpSocket;
                    }
                    try
                    {
                        nReceiveAsyncResult = nSocket.BeginReceive(udpRecvBuffer, 0, BUFFER_SIZE, SocketFlags.None, new AsyncCallback(ReceiveAsync), nSocket);
                    }
                    catch (Exception e)
                    {
                        Debug.LogError(string.Format("Kcp Socket receive exception : {0}", e.Message));
                        nSocket.Close();
                        lock (mSocketLock)
                        {
                            if (mState != ModuleState.CLOSE)
                            {
                                downTriggerFlag = true;
                                mState = ModuleState.CLOSE;
                            }
                        }
                    }
                }
            }
        }


        /********************
         **** mono funcs ****
         *******************/
        void Destroy()
        {
            mState = ModuleState.EXIT;
            if (mUdpSocket != null)
            {
                mUdpSocket.Close();
                mUdpSocket = null;
            }
            if (mRecvThread != null)
            {
                mRecvThread.Abort();
                mRecvThread = null;
            }
        }

        void OnApplicationQuit()
        {
            mState = ModuleState.EXIT;
            if (mUdpSocket != null)
            {
                mUdpSocket.Close();
                mUdpSocket = null;
            }
            if (mRecvThread != null)
            {
                mRecvThread.Abort();
                mRecvThread = null;
            }
        }

        void OnApplicationPause(bool vPause)
        {
            if (vPause)
            {
                if (mState == ModuleState.NORMAL)
                {
                    mState = ModuleState.PAUSE;
                    mMessageCounter.Show("KCP");
                }
            }
            else
            {
                if (mState == ModuleState.PAUSE)
                {
                    mState = ModuleState.NORMAL;
                }
            }
        }
        
        void Update()
        {
            // udp down call
            lock (mSocketLock)
            {
                if (downTriggerFlag)
                {
                    downTriggerFlag = false;
                    OnUdpDown();
                }
            }
            if (mState == ModuleState.NORMAL)
            {
                // kcp message call
                List<byte[]> nList = mUnpackTool.popAll();
                if (nList != null && kcpRecvCall != null)
                {
                    int length = nList.Count;
                    if (length > 0)
                    {
#if SLUA
                        ((SLua.LuaFunction)kcpRecvCall).call(nList, length);
#else
						( (Action<List<byte[]>, int>)kcpRecvCall )(nList, length);
#endif
                    }
                }
                // udp message call
                lock (mUdpMessageQueue)
                {
                    while (mUdpMessageQueue.Count > 0)
                    {
                        var data = mUdpMessageQueue.Dequeue();
                        OnUdpMessage(data);
                    }
                }
                KcpExpandUpdate();
            }
        }


    }
}
