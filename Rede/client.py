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

	file = open(file_name, "r")
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

	destIp = IP.split('.')
	myIp = MYIP.split('.')
	mask = MYMASK.split('.')

	myISR=""
	net=""
	for i in range(0,4):
		myISR += str(int(myIp[i]) & int(mask[i]))
		net += str(int(destIp[i]) & int(mask[i]))

	if(net == myISR): # compara se for igual manda para entrada caso for diferente manda para o gateway.
		response = subprocess.Popen(['bash', 'client.sh', IP, file_name], stdout=subprocess.PIPE).communicate()[0]

	else:
		# response = subprocess.Popen(['bash', 'client.sh', MYGATEWAY, file_name], stdout=subprocess.PIPE).communicate()[0]

	print response
