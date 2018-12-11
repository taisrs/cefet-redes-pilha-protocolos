import socket
from collections import namedtuple
iface = namedtuple("iface", "name ip mask gateway port physicalconn")

MYPORT=5006
PORT=3003

def getnet(ip, mask):
	myIp = ip.split('.')
	myMask = mask.split('.')
	net=""
	for i in range(0,4):
		net += str(int(myIp[i]) & int(myMask[i]))
	return net

ifaces=[]
for i in range(0,1):
	ifaces.append(iface("eth0", "192.168.0.2", "255.255.255.0", "192.168.0.1", PORT, "localhost"))

#cria sockets diferentes para receber clientes
client = socket.socket(socket.AF_INET,socket.SOCK_STREAM)

#conecta o socket que liga com a camada fisica.
client.bind(('localhost',MYPORT))
client.listen(1)

#While para ler dos sockets
while True:
	#recebe conexao, alguem tentou ligar com a porta determinada
	conn, addr = client.accept()
	#abre o segment.txt criado pela camada fisica.
	file=open("package.txt","r")
	#le o segment.txt
	package=file.read()

	DESTINATION = '192.168.0.1'

	for iface in ifaces:
		if getnet(iface.ip,iface.mask)==getnet(DESTINATION,iface.mask):
			server = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
			server.connect((iface.physicalconn,iface.port))
			server.sendall(package)
			response=server.recv(4096)
			server.close()

	conn.send(response)
	conn.close()
