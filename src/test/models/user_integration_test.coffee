vows = require('vows')
assert = require('assert')
{User} = require('../../app/models/user')

vows.describe('User Model').addBatch(
  'Save operation':
    topic: () ->
      _that = this
      user = new User(email: "alex@gmail.com", password: "tPassword", sessionId: "bdsgdhjsg", sessionSecret: "632876782dd")
      user.save((err, saved) ->
        if (err?)
          _that.callback.call(this, err)
        else
          User.findById(saved._id, (err, finded) ->
              _that.callback.call(this, err, finded, user)
          )
      )
    'test saving': (err, saved, original) ->
      console.log 'start save test'
      throw err if err?
      assert.strictEqual(saved.email, original.email, "emails do not match")
      assert.strictEqual(saved.password, original.password, "passwords do not match")
      assert.strictEqual(saved.sessionId, original.sessionId, "sessionIds do not match")
      assert.strictEqual(saved.sessionSecret, original.sessionSecret, "sessionSecrets do not match")
    teardown: (err, saved, original) ->
      console.log 'cleanup the db state'
      User.remove({email: "alex@gmail.com"}, (err) -> throw err if err? )
).run((results) ->
  console.log 'test finished'
  JSON.stringify(results)
)