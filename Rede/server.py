import socket
from collections import namedtuple
iface = namedtuple("iface", "name ip mask gateway port physicalconn")

MYPORT=3006
PORT=3009
HOST='localhost'

def getnet(ip, mask):
	myIp = ip.split('.')
	myMask = mask.split('.')
	net=""
	for i in range(0,4):
		net += str(int(myIp[i]) & int(myMask[i]))
	return net

ifaces=[]
for i in range(0,1):
	ifaces.append(iface("eth0", "192.168.1.1", "255.255.255.0", "192.168.1.2", 3006, "localhost"))


#cria sockets diferentes para receber clientes
client = socket.socket(socket.AF_INET,socket.SOCK_STREAM)

#conecta o socket que liga com a camada fisica.
client.bind((HOST,MYPORT))
client.listen(1)

#While para ler dos sockets
while True:
	#recebe conexao, alguem tentou ligar com a porta determinada
	conn, addr = client.accept()
	#abre o datagram.txt criado pela camada fisica.
	file=open("datagram.txt","r")
	#le o datagram.txt
	lines=file.readlines()
	payload=""
	for i in lines:
		if "##############################" in i:
			b=i.split("##############################") # a esquerda do ############################## tem se as informacoes de origin e destination adress escritas em client.py
			payload+=b[1]
		else:
			payload+=i

	a=b[0].split('|')
	SOURCE=a[0].split(':')[1]
	DESTINATION=a[1].split(':')[1] #deve ser esse codigo obviamente.
	file.close()

	file=open("segment.txt","w")
	file.write(payload)
	file.close()

	server = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
	server.connect((HOST,PORT))
	response=server.recv(4096)
	server.close()

	conn.send(response)
	conn.close()
