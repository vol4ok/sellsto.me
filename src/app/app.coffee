express = require('express')
ejs = require 'ejs'
{auth} = require('./connect/auth')
{User} = require('./models/user')
{defer} = require("node-promise")
authModel = require('./models/auth')
{Cookie} = require('./connect/cookie')
{LoginModule} = require('./controllers/login')
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
  app.use(auth())
  app.use(app.router)
  ## configure view engine
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
appSecure.listen(CFG.SECURE_PORT, CFG.INTERFACE)

platform =
  app: app
  appSecure: appSecure
  authModel: authModel
  defer: defer ##promises support
  User: User
  Cookie: Cookie

new LoginModule(platform) ##initialize a login module