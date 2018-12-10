#!/bin/bash

if [ $# -ne 2 ]; then
	echo "Sintaxe: $0 <IP_ADDRESS> <FILE_NAME> " 1>&2;
	exit 1;
fi

sleep 1;

#define número da porta
PORT=3000;
#carrega o payload
payload=$(cat $2);
#obtém MAC da máquina de origem
macOrig=$(ifconfig | grep -o -m 1 "..:..:..:..:..:..");
#obtém MAC da máquina de destino
macDest=$(arp $1 | grep -o -m 1 "..:..:..:..:..:..");
#monta o cabeçalho da PDU
head=$(echo "Src: $macOrig, Dst: $macDest");

#monta o quadro de envio
frame=$(printf "$head########################################$payload");

#enquanto o número sorteado for maior ou igual a "x", considera uma colisão
while true
do
	#envia quandro convertido em bytes
	echo -n $frame | perl -lpe '$_=unpack"B*"' | nc -W 1 $1 $PORT;

	#sorteia um número aleatório de 0 a 10 (inclusive)
	DIV=$((10+1));
	R=$(($RANDOM%$DIV));

	if [ $R -ge 10 ]; then
    	###echo "colision detected...";

    	DIV=$((10+1));
		R=$(($RANDOM%$DIV));

		###echo "waiting for $R seconds...";

		#aguarda de 0 a 10 segundos para reenviar o quadro
		sleep $R;
	else
		break;
	fi

done

###echo "success!";
