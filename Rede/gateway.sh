#!/bin/bash

#define número da porta
MYPORT=3003;
#define número do IP
MYIP="127.0.0.5";
#define número da porta do servidor da aplicação
PORT=3011;
#define número do IP do servidor da aplicação
IP="127.0.0.5";

#bash cria o coprocesso que vai escutar o canal de comunicação na porta especificada
coproc nc -l -k $MYIP $MYPORT;

#redireciona o quadro recebido para o descritor ${COPROC[1]}
while read -r cmd
do
	#redireciona o quadro para o arquivo especificado
	echo $cmd | perl -lpe '$_=pack"B*",$_' | awk -F"########################################" '{ print $2 $3 }' > ler.txt
	#abre a conexão com o servidor da aplicação e encerra após receber 1 pacote de resposta
	nc -W 1 $IP $PORT
done <&${COPROC[0]} >&${COPROC[1]}
#a resposta está disponível para leitura através do descritor ${COPROC[0]}