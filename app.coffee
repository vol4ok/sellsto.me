express  = require 'express'
stylus = require 'stylus'
jade = require 'jade'
{exec} = require 'child_process'
url = require 'url'

app = express.createServer()
app.use(express.bodyParser())
app.use(app.router)

# compile = (str, path) ->
#   return stylus(str)
#     .set('filename', path)
#     .set('compress', true)
    
# app.use (req, res, next) ->
#   return next() if req.method isnt 'GET' and req.method isnt 'HEAD'
#   path = url.parse(req.url).pathname
#   if /\/(\S+)\.js$/.test(path)
#     target = /\/(\S+)\.js$/.exec(path)[1]
#     console.log 'compile', target
#     exec "cake build:#{target}", (err, stdout, stderr) -> 
#       throw err if err
#       console.log stdout + stderr
#       next()
#   else
#     next()
    
# app.use stylus.middleware
#   src: __dirname + '/styles'
#   dest: __dirname + '/public'
#   compile: compile

app.use (req, res, next) ->
  return next() if req.method isnt 'GET' and req.method isnt 'HEAD'
  path = url.parse(req.url).pathname
  console.log path
  if path == '/'
    exec "cake build", (err, stdout, stderr) -> 
      if err
        console.log 'build - FAIL!\n' + stdout + stderr
        res.send("<pre>#{stdout + stderr}</pre>") 
      else
        console.log 'build - OK!'
        next()
  else
    next()
app.use express.static(__dirname + '/app')

# app.get '/', (req, res, next) ->
#   console.log req.method, req.url
#   res.render('index.jade')
	
	
app.listen(3000)
console.log('server listening on port 3000');