###
* A collection of helper functions for working with cookies objects
* @author Aliaksandr Zhuhrou
* Taken from connect/lib/middleware/session/cookie.js
* version of connect: 1.8.7
###
$ = require('core.js')
util = require('util')


### Defines operations on cookie ###
class Cookie
  name: null
  value: null
  path: '/'
  httpOnly: true
  secure: false
  domain: null
  ### @type {Number} ###
  _maxAge: 14400000
  _now: new Date()

  ###
  * Initialize a new `Cookie` with the given `options`.
  * @param {Object} options
  * @api private
  ###
  constructor: (options) ->
    @__defineSetter__("expires", (date) ->
      throw new Error("Illegal argument type #{typeof date}") unless date instanceof Date
      @._maxAge = date.getTime() - @_now.getTime()
      return this
    )
    @__defineGetter__("expires", ->
      return new Date(@_now.getTime() + @._maxAge)
    )
    @__defineSetter__("maxAge", (maxAge) ->
      @_maxAge = maxAge
      return this
    )
    @__defineGetter__("maxAge", ->
      return @_maxAge
    )
    @__defineGetter__("data", ->
      expires: @expires
      secure: @secure
      httpOnly: @httpOnly
      domain: @domain
      path: @path
    )
    $.extend(this, options) if (options?)

  ### @return a json representation of cookie ###
  toJSON: -> @data

  ### @return {String} representation of a cookie object ###
  serialize: ->
    throw new Error("name and value attributes are required") unless @name? and @value?
    pairs = [@name + '=' + encodeURIComponent(@value)]
    pairs.push('domain=' + @domain) if (@domain)
    pairs.push('path=' + @path) if (@path)
    pairs.push('expires=' + @expires.toUTCString()) if (@expires)
    pairs.push('httpOnly') if (@httpOnly)
    pairs.push('secure') if (@secure)
    return pairs.join('; ')

exports.Cookie = Cookie