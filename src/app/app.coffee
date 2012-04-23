express   = require 'express'
websocket = require('websocket.io')
cfg       = require('./config')

#dev
require('colors')
util = require('util')

app = connect()
app.use(connect.static(cfg.static))
app.use(connect.bodyParser())

app.use (req, res) ->
  console.log req.body
  res.end('OK!')

app.on 'listening', ->
  console.log("Server listening on #{cfg.interface}:#{cfg.port}".green)
  ws = websocket.attach(app)
  ws.on 'connection', (client) ->
    console.log 'connect'.green, client
    client.on 'message', (data) ->
      console.log 'message'.magenta, data
    client.on 'close', ->
      console.log 'close'.yellow, client
      
user = new User()
  
processRequest = (data) ->

module.exports = app

app.listen(cfg.port, cfg.interface)