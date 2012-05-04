#contains object that responsible for security
crypto = require('crypto')

### Generates a derived key representations for a user password###
class PassHasher
  ### A salt @type {string} ###
  salt: '3278jjkds3'
  ### A derived key length @type {Number} ###
  length: 128
  ### An iteration count @type {Number} ###
  iters: 10000

  ###
  * calculates a hash for a given password
  * @param password - a password string
  * @param callback - function(err, key) {} where key is a derived key
  ###
  hash: (password, callback) ->
    crypto.pbkdf2(password, @salt, @iters, @length, (err, key) ->
      callback(err, key)
      return
    )
    return

  ###
  * validates that a given password produces
  * a given derived key
  * @param {string} password a password
  * @param {string} hash a derived key
  * @param {function(boolean, boolean)} a callback where
  *        a first argument indicates whenever the error happened
  *        and a second argument indicates whenever the validation passed.
  ###
  validatePass: (password, hash, callback) ->
    crypto.pbkdf2(password, @salt, @iters, @length, (err, derivedKey) ->
      if (err?)
        callback(true, false)
      else
        if (derivedKey == hash)
          callback(false, true)
        else
          callback(false, false)
    )
    return

#singleton?
exports.passHasher = new PassHasher()