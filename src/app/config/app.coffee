express  = require 'express'
mongoose = require 'mongoose'
ejs      = require 'ejs'

app = express.createServer()

app.configure ->
  @BASE_DIR = process.cwd()
  cfg = JSON.parse($.readFileSync(__dirname + '/config.json', 'utf-8'))
  @cfg = cfg[@settings.env] or {}
    
  # uses
  @use(express.bodyParser())
  @use(@router)
  @use(express.static(__dirname + '/public'))
  
  # setup view engines
  @set('views', __dirname + '/views')
  @set('view options', {open: '{{', close: '}}'})
  @set('view engine', 'ejs')
  
  @db = mongoose
  
app.configure 'development', ->
  @use express.logger('short')
  
app.configure 'production', ->
  
module.exports = app