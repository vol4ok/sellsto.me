express  = require 'express'
{exec} = require 'child_process'
url = require 'url'

app = express.createServer()
app.use(express.bodyParser())
app.use(app.router)

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
	
app.listen(3000)
console.log('server listening on port 3000');