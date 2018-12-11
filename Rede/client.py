import sys
import os
import subprocess
from collections import namedtuple
iface = namedtuple("iface", "name ip mask gateway physicalconn")

MYIP = "192.168.1.1"
MYMASK = "255.255.255.0"

def getnet(ip, mask):
	myIp = ip.split('.')
	myMask = mask.split('.')
	net=""
	for i in range(0,4):
		net += str(int(myIp[i]) & int(myMask[i]))
	return net

ifaces=[]
for i in range(0,1):
	ifaces.append(iface("eth0", "192.168.1.1", "255.255.255.0", "192.168.1.2", "localhost"))


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

	net = getnet(IP,MYMASK)
	v=0
	for iface in ifaces:
		if getnet(iface.ip,iface.mask)==net:
			response = subprocess.Popen(['bash', 'client.sh', iface.physicalconn, file_name], stdout=subprocess.PIPE).communicate()[0]
			v=1
	if v==0: #send to default gateway
			response = subprocess.Popen(['bash', 'client.sh', 'localhost', file_name], stdout=subprocess.PIPE).communicate()[0]





	print response
