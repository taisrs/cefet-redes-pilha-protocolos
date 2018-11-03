#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Sintaxe: $0 <reader_file_name> " 1>&2;
	exit 1;
fi

#define número da porta
PORT=3003;

#bash cria o coprocesso que vai escutar o canal de comunicação na porta especificada
coproc nc -l -k $PORT;

#redireciona o quadro recebido para o descritor ${COPROC[1]}
while read -r cmd
do
	#imprime o número de bytes do quadro recebido
	echo $(echo $cmd | wc -c)
	#redireciona o quadro para o arquivo especificado
	echo $cmd | perl -lpe '$_=pack"B*",$_' | awk -F"########################################" '{ print $NF }' > $1
done <&${COPROC[0]} >&${COPROC[1]}
#a resposta está disponível para leitura através do descritor ${COPROC[0]}
