express = require('express')
ejs = require 'ejs'
{auth} = require('./connect/auth')
fs = require('fs')
#dev require
require('colors')
util = require('util')

viewDir = __dirname + '/views'

### configures a given app ###
configureApp = (app, viewEngine, viewDir) ->
  app.use(express.static(CFG.STATIC))
  app.use(express.bodyParser())
  app.use(express.cookieParser())
  app.use(app.router)
  app.use(auth())

  app.register('.html', viewEngine)
  app.set('view engine', 'html')
  app.set('views', viewDir)


httpsOptions =
  key: fs.readFileSync("#{__dirname}/ssl/sellstome.key").toString()
  cert: fs.readFileSync("#{__dirname}/ssl/sellstome.crt").toString()

##create http server
app = express.createServer()
configureApp(app, ejs, viewDir)

app.get '/', (req, res) ->
  res.render 'dashboard.wa', layout: no

app.listen(CFG.PORT, CFG.INTERFACE)

##create a secure server
appSecure = express.createServer(httpsOptions)
configureApp(appSecure, ejs, viewDir)

appSecure.get '/register', (req, res) ->
  res.render 'register'

appSecure.get '/login', (req, res) ->
  stack = new Error().stack
  console.log( stack )
  res.render 'login'

appSecure.listen(CFG.SECURE_PORT, CFG.INTERFACE)