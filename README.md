# cefet-redes-pilha-protocolos
Trabalho da disciplina de Redes I sobre a pilha de protocolos TCP/IP

## Teste individual - Camada Física
1) Iniciar o servidor:
./server.sh recebido.txt
2) Executar o cliente:
./client.sh 127.0.0.1 mensagem.txt

## Teste individual - Camada Aplicação
1) Iniciar o servidor da aplicação:
node server.js
2) Iniciar o servidor da camada física:
./server.sh
3) Iniciar o cliente da aplicação:
node client.js
4) Iniciar o serviço no navegador:
http://localhost:3000/
