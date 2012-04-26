db = require('../db')

class User
 email: null
 password: null
 sessionId: null
 sessionSecret: null

 constructor: (@email, @password) ->

 save: () ->
