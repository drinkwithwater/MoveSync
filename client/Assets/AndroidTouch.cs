using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Scripting;
using System.Collections;
using System;
using SG.Network.skynet;
using SG;
using System.Collections.Generic;

class AngleDirect {
    public int angle;
    public int speed;
    public AngleDirect(int a,int b) {
        angle = a;
        speed = b;
    }
}

class Oper{
    private AndroidTouch item = null;
    private bool toggle = false;
    public int speed = 6;
    private Vector2 direct;
    private Vector2 center;
    public Oper(AndroidTouch i) {
        direct = new Vector2(0, 0);
        center = new Vector2(0, 0);
        item = i;
    }
    public void mouseClick(float x, float y) {
        if (!toggle) {
            toggleIn(x, y);
        } else {
            toggleOut();
        }

    }
    public void mouseUpdate(float x, float y) {
        if (toggle) {
            inToggleOne(x, y);
        }
    }

    public void touchZero() {
        toggleOut();
    }
    public void touchOne(float x, float y) {
        if (!toggle) {
            toggleIn(x, y);
        } else {
            inToggleOne(x, y);
        }
    }

    void toggleIn(float x, float y) {
        center.x = x;
        center.y = y;
        toggle = true;
        item.showPanel(x, y);
    }
    void inToggleOne(float x, float y) {
        direct.x = x - center.x;
        direct.y = y - center.y;
    }
    void toggleOut() {
        direct.x = 0;
        direct.y = 0;
        toggle = false;
    }

    public void frameUpdate() {
        if (toggle) {
            float rr = (float)Math.Pow(direct.x * direct.x + direct.y * direct.y, 0.5f);
            if (rr != 0) {
                int angle = ((int)(180 * Math.Atan2(direct.y, direct.x) / Math.PI) % 360+360)%360;
                item.operMove(angle);
            }
        } else {
            item.operMove(-1);
        }
    }

}

public class AndroidTouch : MonoBehaviour {

    public Transform cube = null;
    public Transform touchPanel = null;
    public bool useMouse = false;

    private uint lastUpdateTime = TimeHelper.GetMilliseconds();

    private uint lastFrameTime = TimeHelper.GetMilliseconds();
    private int frame= 0;
    private AngleDirect dir = new AngleDirect(0, 0);

    private double toleranceX = 0.0;
    private double toleranceY = 0.0;
    private int toleranceFrame = 64;

    private Transform self = null;
    private Camera selfCamera = null;
    private Oper oper = null;
    private KcpSocket kcpSocket = null;
    private Action<int> onConnect=(a)=> {
    };

	// Use this for initialization
	void Start () {
        oper = new Oper(this);
        Input.multiTouchEnabled = true;
        self = GetComponent<Transform>();
        selfCamera = GetComponent<Camera>();
        kcpSocket = GetComponent<KcpSocket>();

        kcpSocket.Init("166.111.132.72", 8888, (Action<List<byte[]>,int>)((List<byte[]> a,int b)=> {
            for (int i = 0; i < a.Count; i++) {
				// deal message( sendFormat="%f %f %f %d %d" -- frame pos.x pos.y dir.angle dir.speed )
                string msg=System.Text.Encoding.Default.GetString(a[i]);
                string [] fposdir=msg.Split();
                float x = float.Parse(fposdir[1]);
                float y = float.Parse(fposdir[2]);

                double deltaX = x - self.position.x;
                double deltaY = y - self.position.y;
                double delta = Math.Pow(deltaX * deltaX + deltaY * deltaY, 0.5);
                if (delta > 0.1) {
                    Debug.Log("delta=" + delta);
                }
                if (delta > 3) {
                    setPosition(x, y);
                } else {
                    toleranceX = deltaX;
                    toleranceY = deltaY;
                    toleranceFrame = 64;
                }

                dir.angle = int.Parse(fposdir[3]);
                dir.speed = int.Parse(fposdir[4]);
                cube.rotation = Quaternion.Euler(0, 0, dir.angle);
            }
        }));
        kcpSocket.Connect(5000,onConnect);
	}
    public void showPanel(float x, float y) {
        float a=(x - Screen.width / 2) / Screen.height * selfCamera.orthographicSize*2;
        float b=(y - Screen.height/ 2) / Screen.height * selfCamera.orthographicSize*2;
        touchPanel.position = new Vector2(a+self.position.x, b+self.position.y);
    }

    public void send(string s) {
        byte [] sByte=System.Text.Encoding.Default.GetBytes(s);
        byte[] allByte = new byte[2 + sByte.Length];
        allByte[0] = (byte)(sByte.Length / 256);
        allByte[1] = (byte)(sByte.Length % 256);
        for (int i = 0; i < sByte.Length; i++) {
            allByte[i+2] = sByte[i];
        }
        kcpSocket.KcpSend(allByte);
    }

    private void setPosition(float x, float y) {
        cube.position = new Vector2(x, y);
        self.position = new Vector3(x, y, self.position.z);
    }
    public void operMove(int angle) {
        send(""+angle);
        touchPanel.rotation = Quaternion.Euler(0, 0, angle);
    }

	// Update is called once per frame
	void Update () {
        if (useMouse) {
            if (Input.GetMouseButtonDown(0)) {
                oper.mouseClick(Input.mousePosition.x, Input.mousePosition.y);
            }
            oper.mouseUpdate(Input.mousePosition.x, Input.mousePosition.y);
        } else {
            if (Input.touchCount <= 0) {
                //oper.touchZero();
            } else {
                var temp = Input.touches[0].position;
                oper.touchOne(temp.x,temp.y);
            }
        }

        uint cur = TimeHelper.GetMilliseconds();
        if (cur - lastFrameTime > 200) {
			// deal input
            oper.frameUpdate();
            lastFrameTime += 200;
            frame++;
        }

        int dt = (int)(cur - lastUpdateTime);
        lastUpdateTime = cur;
        if (dir.speed == 0) {
            return;
        } else {
            double dirAngle = 1.0 * dir.angle / 180 * Math.PI;
            double dirX = dir.speed*Math.Cos(dirAngle);
            double dirY = dir.speed*Math.Sin(dirAngle);
            double dx = dirX * dt / 200;
            double dy = dirY * dt / 200;
            setPosition((float)(self.position.x + dx), (float)(self.position.y + dy));
            if (toleranceFrame > 0) {
                float tolx = (float)(toleranceX / toleranceFrame);
                float toly = (float)(toleranceY / toleranceFrame);
                setPosition((float)(self.position.x + tolx), (float)(self.position.y + toly));
                toleranceFrame--;
            }
        }
    }

    void OnDestroy() {
    }

}
