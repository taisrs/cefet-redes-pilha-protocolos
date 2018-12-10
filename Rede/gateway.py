#!/usr/bin/python3
import sys
import os
import subprocess
import socket
import IPlibrary as ip

PORT=3010
#numero de elementos.
nm_arguments=len(sys.argv)
if nm_arguments == 2:
	file= open("tabelaRotasC.txt","a+")
	lines = file.readlines()
	for i in lines:
		print i
	while(True):
		print "quer adicionar mais 1 elemento na tabela ? 1- sim ,0 - nao.\n Para sair deve ser recusado adicionar uma entrada na Tabela de Rotas"
		while(True):
			i=int(input())
			if(i==0 or i==1):
				break;
		if(i==1):
			print "adicionar ip-rede"
			ipi=ip.inputIP()
			print "adicionar Mask"
			iMask= ip.inputMASK()
			print "adionar ip gateway"
			iG=ip.inputIP()
			file.write(str(ipi)+" "+str(iMask) +" "+ str(iG))
			file.close()
		else:
			break;
elif nm_arguments==1:
	file= open("tabelaRotasC.txt","r")
	lines=file.readlines()
	for line in lines: #chama as interfaces para ficar escutando
		#os.system("gnome-terminal sh python gateway.py 1 "+ str(line.split(' ')[2]))
		string = str(line.split(' ')[2])
		print string
		subprocess.check_output(["gnome-terminal",
                        		 "sh","-x",
                         		 "python", "gateway.py","1",string
                        		])
	print "2"

elif nm_arguments==3:
	file= open("tabelaRotasC.txt","r")
	lines=file.readlines()
	redeAndGateway=[]
	for line in lines:
		tup=line.split(' ')
		redeAndGateway.append([ip.complementoUm( ip.ipBin(tup[0]),ip.ipBin(tup[1]) ),tup[2]])
	HOST=sys.argv[2]
	print str(HOST)

	s= socket.socket(socket.AF_INET,socket.SOCK_STREAM)
	s.bind((HOST,PORT))
	s.listen(1)
	print "hey"
	while True:
		conn, addr = s.accept()
		file=open("ler.txt","r")
		lines=file.readlines()
		for i in lines:
			if "&&&" in i:
				b=i.split("&&&")
				a=i.split("&&&")[0].split('|')
		#e=b[0].split(' ')[0]+' ###'+b[1]		
		#file.write(e)
		SOURCE=a[0].split(':')[1]
		DESTINATION=a[1].split(':')[1] #deve ser esse codigo obviamente.
		#tratar.
		gatewayRetorno=None
		for rg in redeAndGateway:
			if(rg[0]==redeEntrada):
				gatewayRetorno=rg[1]
				break;
		if(gatewayRetorno==None):
			print "erro nao tem Gateway para enviar esse IP"
		else:
			os.system('./gatewayR.sh '+ IP_DESTINO +' '+ O_Q_ENVIA ) # tem que arrumar essa linha ainda.
		#devolver
		s.send()
		conn.close()
