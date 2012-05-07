express = require('express')
eco = require 'eco'
{auth} = require('./connect/auth')
#dev require
require('colors')
util = require('util')

VIEW_DIR = __dirname + '/views'

app = express.createServer()
app.use(express.static(CFG.STATIC))
app.use(express.bodyParser())
app.use(express.cookieParser())
app.use(app.router)
app.use(auth())

app.register('.html', eco)
app.set('view engine', 'html')
app.set('views', VIEW_DIR)
  
app.get '/', (req, res) ->
  res.render 'dashboard.wa', layout: no

app.get '/register', (req, res) ->
  res.render 'register'

app.get '/login', (req, res) ->
  res.render 'login'

app.listen(CFG.PORT, CFG.INTERFACE)