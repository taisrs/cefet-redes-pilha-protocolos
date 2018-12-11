#!/bin/bash

#define número da porta
MYPORT=5003;
#define número do IP
MYIP="localhost";
#define número da porta do servidor da aplicação
PORT=5006;

#bash cria o coprocesso que vai escutar o canal de comunicação na porta especificada
coproc nc -l -k $MYIP $MYPORT;

#redireciona o quadro recebido para o descritor ${COPROC[1]}
while read -r cmd
do
	#redireciona o quadro para o arquivo especificado
	echo $cmd > package.txt
	#abre a conexão com o servidor da aplicação e encerra após receber 1 pacote de resposta
	nc -W 1 $MYIP $PORT
done <&${COPROC[0]} >&${COPROC[1]}
#a resposta está disponível para leitura através do descritor ${COPROC[0]}
