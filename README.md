## Enviroment

client: unity

server: skynet
		cp -r server skynet/sth
		cd sth
		./run.sh


## Main Logic:

### server:

[server/moveUdpServer.lua:](server/moveUdpServer.lua)
		skynet.fork(function()
			while(true) do
				for nFd, nConn in pairs(mFdToConn) do
					nConn:onUpdateFrame()
				end
				-- update frame per 200ms
				skynet.sleep(20)
			end
		end)

[server/src/kcpBindConnection.lua:](server/src/kcpBindConnection.lua)

		-- when recv message
		function KcpBindConnection:dispatchMessage(vMsg)
			...
				local angle=tonumber(vMsg)
				if angle>=0 then
					local speed=6
					self:onMoveAction({angle=angle,speed=speed})
				else
					local speed=0
					self:onMoveAction({angle=angle,speed=0})
				end
			...
		end

		function KcpBindConnection:onMoveAction(dir)
			self.moveAction=dir
			-- init
			if not self.startMove then
				self.startMove=true
				self.frame=0
				self.dir={
					angle=0,
					speed=0,
				}
				self.pos={
					x=0,
					y=0
				}
			end
		end

		-- called each frame (per 200 ms)
		function KcpBindConnection:processMoveAction()
			if not self.moveAction then
				return
			else
				self.dir=self.moveAction
				self.moveAction=nil
			end
		end

		local function ar2xy(angle,speed)
			local piAngle=angle/180*math.pi
			return speed*math.cos(piAngle), speed*math.sin(piAngle)
		end

		sendFormat="%f %f %f %d %d" -- frame pos.x pos.y dir.angle dir.speed
		-- frame update
		function KcpBindConnection:onUpdateFrame()
			if not self.startMove then
				return
			end
			self.frame=self.frame+1
			local dx,dy=ar2xy(self.dir.angle, self.dir.speed)
			self.pos.x = self.pos.x + dx
			self.pos.y = self.pos.y + dy
			self:processMoveAction()
			local sendMsg=sendFormat:format(self.frame, self.pos.x, self.pos.y, self.dir.angle, self.dir.speed)
			self:doSend(string.pack(">s2",sendMsg))
		end


### client:

[client/Assets/Android.cs:](client/Assets/AndroidTouch.cs)
		// deal message( sendFormat="%f %f %f %d %d" -- frame pos.x pos.y dir.angle dir.speed )
		{
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
		// mono update
		Update(){
				uint cur = TimeHelper.GetMilliseconds();
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
