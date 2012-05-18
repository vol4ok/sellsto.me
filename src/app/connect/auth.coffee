###
* Sellstome auth middleware
* @author Aliaksandr Zhuhrou
###
{passHasher} = require('../models/auth')
{User} = require('../models/user')
util = require('util')
$ = require('core.js')

sessionCookieName = 'sic'

exports.auth = () ->
  return (req, res, next) ->
    if req.cookies?
      if req.cookies.sic?
        try
          {id, sessionId} = parseCookie(req.cookies.sic)
          User.findById(id, (err, user) ->
            if not err?
              if validateSession(sessionId, user)
                req.viewer = user ##set up a viewer
                next() ## we finally pass the validation
              else
                redirectOrRouteToLogin(req, res, next)
            else
              next(err)
          )
        catch e
          return next(e)
      else
        redirectOrRouteToLogin(req, res, next)
    else
      return next(new Error('looks like you have not configured cookieParser middleware'))

redirectOrRouteToLogin = (req, res, next) ->
  if ($.startsWith(req.url, '/login') || $.startsWith(req.url, '/signup'))
    next()
  else
    res.redirect("https://#{CFG.DOMAIN}/login")

### parses a given value in a session cookie ###
parseCookie = ( value ) ->
  throw new TypeError("should be string") unless typeof value == "string"
  separatorIndex = value.indexOf('|')
  throw new Error("Illegal argument: #{value}") if separatorIndex == -1
  return {id: value.substring(0, separatorIndex), sessionId: value.substring(separatorIndex + 1)}

validateSession = (session, user) ->
  return session == user.sessionId