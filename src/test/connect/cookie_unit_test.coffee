vows = require('vows')
assert = require('assert')
util = require('util')
{Cookie} = require('../../app/connect/cookie')

vows.describe('Test cookie model').addBatch(
  'base case':
    topic: -> new Cookie()
    'test defaults': (cookie) ->
      assert.strictEqual(cookie.path, '/', 'path is invalid')
      assert.strictEqual(cookie.httpOnly, true, 'httpOnly should be a default')
      assert.strictEqual(cookie.maxAge, 14400000, 'maxAge does not match')
  'set options':
    topic: -> new Cookie
        name: 'l'
        value: 'accepted'
        path: '/test'
        httpOnly: false
        secure: true
        domain: 'test.com'
        expires: new Date('2014-10-10T12:00:00')
    'test options': (cookie) ->
      assert.strictEqual(cookie.name, 'l', 'name does not match')
      assert.strictEqual(cookie.value, 'accepted', 'value does not match')
      assert.strictEqual(cookie.path, '/test', 'path is invalid')
      assert.strictEqual(cookie.httpOnly, false, 'httpOnly should be false')
      assert.strictEqual(cookie.domain, 'test.com', 'domain is not match')
      console.log "expires is: #{util.inspect(cookie.expires)}"
      assert.strictEqual(cookie.expires.getTime(), new Date('2014-10-10T12:00:00').getTime(), 'expires does not match')
    'test serialize': (cookie) ->
      console.log(cookie.serialize())
).export(module)