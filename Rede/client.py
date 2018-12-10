import sys
import os
import subprocess
import IPlibrary as ip

MYIP = "127.0.0.3"
MYMASK = "255.255.255.0"
MYGATEWAY = "127.0.0.5"

arguments = len(sys.argv)

if arguments == 3: # chamada que o client.rb fara exemplo. Client.py 127.0.0.4 ftp.txt
	IP = sys.argv[1]
	file_name = sys.argv[2]

	file = open(file_name, "r") #escreve no offset o controle que foi feito pelo gateway
	lines = file.readlines()
	payload = ''
	for content in lines:
		payload += content
	header = "Src:" + MYIP + "|Dst:" + IP
	output = header + "##############################" + payload
	file.close()

	file = open(file_name,"w")
	file.write(output)
	file.close()

	# myISR = ip.complementoUm(MYIP, MYMASK) #a partir do ip e da mascara descobrir a rede
	# IP = ip.ipMaskEntrada(IP)  #a partir da entrada descobrir o ip e a mascara.
	# net = ip.complementoUm(ip.ipBin(IP), ip.netMask(IP)) # rede da entrada

	# if(net == myISR): # compara se for igual manda para entrada caso for diferente manda para o gateway.
	response = subprocess.Popen(['bash', 'client.sh', IP, file_name], stdout=subprocess.PIPE).communicate()[0]

	# else:
	# 	response = subprocess.Popen(['bash', 'client.sh', MYGATEWAY, file_name], stdout=subprocess.PIPE).communicate()[0]

	# file = open("response.txt","w")
	# file.write(str(response))
	# file.close()

	print response
