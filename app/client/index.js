PORT = process.argv[2] ? parseInt(process.argv[2]) : 3001;
PID_FILE = '../../tmp/client.pid'
var fs = require('fs');
var express = require('express');
var app = express.createServer();
app.use(express.bodyParser());
app.use(app.router);
app.use(express.static(__dirname + '/public'));
app.listen(PORT);
fs.writeFile(PID_FILE, process.pid.toString() + '\n');