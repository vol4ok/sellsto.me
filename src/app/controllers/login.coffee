## Login and signup module
class LoginModule
  ### initilizes a given module ###
  constructor: (platform) ->
    {@app, @appSecure, authModel, User, @Cookie, @defer} = platform
    {@passHasher, @tokenGenerator} = authModel

    @app.get '/login', (req, res) ->
      res.redirect("https://#{CFG.DOMAIN}/login")

    @appSecure.get '/singup', (req, res) ->
        res.render 'signup'

    @appSecure.post '/signup', (req, res) =>
      success = (req, res) -> res.redirect("http://#{CFG.DOMAIN}/")
      error = (req, res, err) -> res.redirect("http://#{CFG.DOMAIN}/signup")

      user = new User()
      user.email = req.body.user.email
      user.name = req.body.user.name
      user.password = @passHasher.hash(req.body.user.password, (err, hash) ->
        if (err?)
          error(req, res, err)
        else
          user.password = hash
          ##save a given user
          user.save((err) ->
            if (err?)
               error(req, res, err)
            else
               @doLogin(req, res, user).then(() -> success(req, res),
               (err) -> error(req, res, err))
          )
      )

    @appSecure.get '/login', (req, res) ->
      res.render 'login'

    @appSecure.post '/login', (req, res) ->

      return

    return

  ### @returns promise on success of a given operation ###
  doLogin: (req, res, user) ->
    return @generateSession().then( (token) =>
      return @storeSession(req, res, user, token)
    )


  ###
  * set up a login cookie
  * @param req incoming request
  * @param res incoming response
  * @param a user that pass authentification
  ###
  storeSession: (req, res, user, token) ->
    deferred = @defer()
    if user.id?
      user.sessionId = token
      user.save( (err) =>
        if err?
          deferred.reject(err)
        else
          ##we should also store a given session to a cookie
          sessionCookie = new @Cookie
            name: 'sic'
            value: "#{user.id}|#{token}"
            path: '/'
            httpOnly: true
            expires: new Date('2014-10-10T12:00:00') ## todo - fixme zhuhrou a - set some definite period in future
          res.setHeader('Set-Cookie', sessionCookie.serialize())
          deferred.resolve()
      )
    else
      deferred.reject(new Error('user argument should have a defined id'))
    return deferred.promise

  ###
  * generates a new session token
  * @return a promise that generates a session value
  ###
  generateSession: () ->
    return @tokenGenerator.generate()






exports.LoginModule = LoginModule