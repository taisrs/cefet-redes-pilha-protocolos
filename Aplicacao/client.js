const express = require('express');
const formidable = require('formidable');
const fs = require('fs');

const app = express();

// Home page route.
app.post('/fileuploadform', function (req, res) {
	let form = new formidable.IncomingForm();
	form.parse(req, function (err, fields, files) {
		const { execSync } = require('child_process');
		const { path } = files.filetoupload;
		const { name } = files.filetoupload;

		let newpath = './uploads/' + name;

		fs.rename(path, newpath, function (err) {
			if (err) throw err;

			//============================================================================================
			//===================================Fisica===================================================
			//============================================================================================

			console.log('Envia ' + newpath + ' via camada fisica para o servidor');

			data = execSync(`cat ${newpath}`);
			fs.writeFileSync('ftp.txt', `put ${name}:${data}`);
			execSync('./client.sh 127.0.0.1 ftp.txt');

			//============================================================================================
			//===================================Aplicacao================================================
			//============================================================================================

			res.redirect('/');
		});
	});
});

// About page route.
app.get('/fileupload', function (req, res) {
	res.writeHead(200, {'Content-Type': 'text/html'});
	res.write('<form action="fileuploadform" method="post" enctype="multipart/form-data">');
	res.write('<input type="file" name="filetoupload"><br>');
	res.write('<input type="submit">');
	res.write('</form>');
	return res.end();
});

app.get('/filedownload/:file', function (req, res, next) {
	const { execSync } = require('child_process');
	const { file } = req.params;

	//============================================================================================
	//===================================Fisica===================================================
	//============================================================================================

	console.log('Requisita a camada física o arquivo ' + file + ' e o salva em ./downloads');

	fs.writeFileSync('ftp.txt', `get ${file}`);
	response =  execSync('./client.sh 127.0.0.1 ftp.txt');
	fs.writeFileSync('./downloads/' + file, response);

	//============================================================================================
	//===================================Aplicacao================================================
	//============================================================================================

	res.download('./downloads/' + file, file);
});


app.get('/', function (req, res) {
	const { exec } = require('child_process');
	const { execSync } = require('child_process');

	//============================================================================================
	//===================================Fisica===================================================
	//============================================================================================

	console.log('Requisita a camada física a lista de arquivos no servidor e salva em ./filelist.txt');

	fs.writeFileSync('ftp.txt', 'ls .');
	response =  execSync('./client.sh 127.0.0.1 ftp.txt');
	fs.writeFileSync('filelist.txt', response);

	//============================================================================================
	//===================================Aplicacao================================================
	//============================================================================================

	exec('cat filelist.txt', function (err, stdout, stderr) {
		if (err) {
			res.end('Erro na conexão com o servidor!');
		}
		str = stdout.split(';');
		ret = "<h3> Arquivos no servidor: </h3>";
		function logArrayElements(element, index, array) {
			ret += '<a href="./filedownload/' + element + '">' + element + "</a><br>";
		}
		str.forEach(logArrayElements);
		res.end(ret);
	});
});

app.listen(3000);
