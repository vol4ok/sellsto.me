## test the connection to a redis server
vows = require('vows')
assert = require('assert')
util = require('util')
redis = require('redis')

vows.describe('test redis connection').addBatch(
  'connect':
    topic: ->
      _that = this
      client = redis.createClient()
      client.on('error', (err) -> console.log("Something wrong #{err}"))
      client.set('test1', 'test value', redis.print)
      client.get('test1', _that.callback)
      client.quit()
      return
    'redis-connect': (err, reply) ->
      assert.strictEqual(reply, 'test value', 'return from redis does not match')
).run()