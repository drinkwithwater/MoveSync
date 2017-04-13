## Enviroment

client: unity

	1. import in unity
	2. set server ip in AndroidTouch component

server: skynet

	cp -r server skynet/udpserver
	cd skynet/udpserver
	chmod +x run.sh
	./run.sh


## Message

client to server:

	angle

server to client:

	frame pos.x pos.y angle speed


## Mechanism

[wiki(Only Chinese...)](https://github.com/drinkwithwater/MoveSync/wiki)
