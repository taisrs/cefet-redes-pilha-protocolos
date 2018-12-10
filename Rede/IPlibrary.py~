def MascarasPossiveis():
	lista=potencias2(8)
	listaRetorno=[]
	inteiroManipulado=0
	listaRetorno.append(inteiroManipulado)
	for i in lista:
		inteiroManipulado+=i
		listaRetorno.append(inteiroManipulado)
	return listaRetorno

def netMask(a):
	MascaraIP=""
	for i in range(0,32):
		#print str(i) +" " + str(entradaIP[1])
		if (i%8==0 and i!=0):
			MascaraIP+='.'
		if (i < int(a)):
			MascaraIP+='1'
			#print i
		else:	
			#print "to aqui
			MascaraIP+='0'
	
	return MascaraIP	

def inputPORT():
	while True:
		a=input()
		if a > 65535:
			print "deve ser menor que 65536"
		elif a < 1024:
			print "deve ser maior que 1023"
		else:
			break	
	return a

def potencias2(a):
	a=a-1
	lista=[]
	for i in range(int(a),-1,-1):
		lista.append(pow(2,i))
	return lista	

def ipBin(a):
	listinha=potencias2(8)
	ipBin=""
	for z in a.split('.'):
		for i in listinha:
			if(int(z)>=i):
				ipBin+='1'
				z=int(z)-i
			else:
				ipBin+='0'
	return ipBin

def complementoUm(a,b):
	listaA=a.split('.')
	listaB=b.split('.')
	retornoIPrede=""
	for z,i in zip(listaA,listaB):
		for w,e in zip(z,i):
			if(w==1 and e==1):
				retornoIPrede+='1'
			else:	
				retornoIPrede+='0'
		retornoIPrede+='.'
	retornoIPrede=retornoIPrede[:-1]
	return retornoIPrede

def inputIP():
	controle=False
	foraFaixa=False
	while(not controle):
		entrada = raw_input()
		if(entrada.count('.')!=3):
			controle=False
			print "formato errado, entre com outro IP seguindo part1.part2.part3.part4"
		else:
			entradaTups=entrada.split('.')
			for i in entradaTups:
				i=int(i)
				if(i>255 or i<0):
					foraFaixa=True
					print "uma das partes tem um valor fora do padrao( 0 a 255 )"
			if(foraFaixa):
				controle=False
			else:
				controle=True
	return entrada

def inputMASK():
	listaM=MascarasPossiveis()
	menor255=False
	controle=False
	while(not controle):
		controle=True
		entrada = raw_input()
		#tem que ter 4 partes part1.part2.part3.part4
		if(entrada.count('.')!=3):
			controle=False
			print "formato errado, entre com outra Mascara seguindo part1.part2.part3.part4"
		else:
			entradaTups=entrada.split('.')
			for i in entradaTups:
				i=int(i)
				if(not menor255):
					NMP=False
					for o in listaM:
						if (i == o):
							NMP=True
							if(i != listaM[8]):
								menor255=True
							break
				else:
					NMP=True
					if( i!= 0):
						NMP=False
				if(not NMP):
					if(menor255):
						print "as outras partes, apos a parte que nao eh 255, que nao eh igual 0 deve ser igual" + str(i)+ " " + str(o)
					else:
						print "as partes tem que ser alguma das seguintes para ser mascara: " + str(listaM)
					controle=False
					break
			#deu tudo certo
			#print "tudo okay"		
	return entrada

def ipMaskEntrada(entradaIP):
	if(entradaIP.count('/') == 1):
		entradaIP = entradaIP.split('/')
	else:
		entradaIP =list(entradaIP)
		entradaIP.append('24')
	return entradaIP
	