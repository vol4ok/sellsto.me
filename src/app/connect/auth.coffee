###
* Sellstome auth middleware
* @author Aliaksandr Zhuhrou
###
{passHasher} = require('../models/auth')
{User} = require('../models/user')

sessionCookieName = 'sic'

exports.auth = () ->
  return (req, res, next) ->

    return