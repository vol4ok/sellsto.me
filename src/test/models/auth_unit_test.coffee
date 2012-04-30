# tests some aspects of the node.js cryptography
vows = require('vows')
assert = require('assert')
crypto = require('crypto')
util = require('util')
{User} = require('../../app/models/user')

salt = '3278jjkds3'
length = 128
iters = 10000
password = "password"

vows.describe('Test standart functions').addBatch(
    'PBKDF2':
      topic: () ->
        _that = this
        crypto.pbkdf2(password, salt, iters, length, (err, key) ->
          if (err?)
            _that.callback.call(this, err)
          else
            console.log(key)
            originalHash = key
            crypto.pbkdf2(password, salt, iters, length, (err, key) ->
              if (err?)
                _that.callback.call(this, err)
              else
                _that.callback.call(this, err, key, originalHash)
            )
        )
      'test hashing': (err, recurrentHash, originalHash) ->
        assert.strictEqual(recurrentHash, originalHash, "hashes does not match")
#     temp code that used for populating a test user before the login page is ready.
#    'save test user':
#      topic: () ->
#        _that = this
#        crypto.pbkdf2(password, salt, iters, length, (err, key) ->
#          user = new User(email: "zhygrr@gmail.com", password: key, sessionId: "bdsgdhjsg", sessionSecret: "632876782dd")
#          user.save((err, saved) ->
#            console.log 'saved test user'
#            if (err?)
#              _that.callback.call(this, err)
#            else
#              User.findById(saved._id, (err, finded) ->
#                _that.callback.call(this, err, finded, user)
#              )
#          )
#        )
#        return
#      'saving': ->
#        return
).run((results) ->
  console.log 'test finished'
  JSON.stringify(results)
)