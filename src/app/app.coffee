express   = require 'express'
eco = require 'eco'
VIEW_DIR = __dirname + '/views'

#dev require
require('colors')
util = require('util')

app = express.createServer()
app.use(express.static(CFG.STATIC))
app.use(express.bodyParser())
app.use app.router

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