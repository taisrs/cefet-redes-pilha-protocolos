import socket

MYPORT=3006
PORT=3009

HOST='127.0.0.1'
MASK='255.255.255.0'
GATEWAY='127.0.0.5'


#cria sockets diferentes para receber clientes
client = socket.socket(socket.AF_INET,socket.SOCK_STREAM)

#conecta o socket que liga com a camada fisica.
client.bind((HOST,MYPORT))
client.listen(1)

#While para ler dos sockets
while True:
	#recebe conexao, alguem tentou ligar com a porta determinada
	conn, addr = client.accept()
	#abre o segment.txt criado pela camada fisica.
	file=open("datagram.txt","r")
	#le o segment.txt
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

	if (DESTINATION==HOST):
		server = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
		server.connect((HOST,PORT))
		response=server.recv(4096)
		server.close()
		#aqui significa que ele recebeu corretamente.

	# minhaRede=ip.complementoUm(HOST,MASK)
	# entradaIP= ip.ipMaskEntrada(SOURCE)

	# rede=ip.complementoUm(ip.ipBin(entradaIP[0]),ip.netMask(entradaIP[1]))

	#isso aqui ta errado.
	# file=open("segment.txt","r+")
	# lines=file.readlines()
	# nem_content="source adress:"+HOST+"|destination adress:"+SOURCE+"&&&"
	# for i in lines:
	# 	new_content+=i
	# file.write(new_content)
	# file.close()

	conn.send(response)
	conn.close()
