const fs = require('fs');                   // importa o módulo 'file system'
const path = require('path');              // importa o módulo 'path' para recuperar a extensão de arquivos
const net = require('net');

const server = net.createServer(service);

function service(socket) {
    // leitura assíncrona do arquivo de comandos
    fs.readFile('command.txt', function(err, msg) {  // lê o arquivo de comandos (PDU)
        if (err) {
            return console.error(err);
        }

        const cmd = msg.toString('utf8').replace(/\n$/, '');

        console.log(cmd);

        switch(cmd.split(' ')[0]) {
            case 'ls':
                fs.readdir(cmd.split(' ')[1], function(err, list) {
                    if (err) {
                        return console.error(err);
                    }
                    socket.write(list.join().replace(/,/g, ';'));
                    socket.destroy();
                });  // lê o conteúdo de um diretório
                break;
            case 'get':
                fs.readFile(cmd.split(' ')[1], function(err, file) {
                    if (err) {
                        return console.error(err);
                    }
                    socket.write(file);
                    socket.destroy();
                }); // lê o conteudo de um arquivo
                break;
            case 'put':
                const data = cmd.split(' ')[1].split(':')[1];
                fs.writeFile(cmd.split(' ')[1].split(':')[0], data, function(err, file) {
                    if (err) {
                        return console.error(err);
                    }
                    socket.write('Successfully uploaded.');
                    socket.destroy();
                }); // escreve um novo arquivo
                break;
            default:
                console.log('Command not found');
        }
    });
}

server.listen(3012, '127.0.0.1');
