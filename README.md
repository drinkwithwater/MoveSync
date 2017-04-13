## Mechanism

[wiki(Only Chinese...)](https://github.com/drinkwithwater/MoveSync/wiki)

## Enviroment

client: unity

	import in unity
	set server ip in AndroidTouch component of MainCamera Node.

server: skynet

	cp -r server skynet/udpserver
	cd skynet/udpserver
	chmod +x run.sh
	./run.sh

