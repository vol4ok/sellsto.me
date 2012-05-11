##generates a sequence of random data.
$ = require('core.js')

##generates a next double
exports.nextDouble = (upperExclusive) ->
  throw new TypeError("invalid argument type #{typeof upperExclusive}") unless $.isNumber(upperExclusive)
  return Math.random() if arguments.length == 0
  return upperExclusive * Math.random()
##generates a next int
exports.nextInt = (upperExclusive) ->
  throw new TypeError("invalid argument type #{typeof upperExclusive}") unless $.isNumber(upperExclusive)
  return Math.floor(upperExclusive * Math.random())
##generates a random string of a given lenght
charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
exports.randomString = (strLength) ->
  randomString = ''
  for position in [0..strLength]
    charPoz = Math.floor(Math.random() * charset.length)
    randomString += charset.substring(charPoz, charPoz+1)
  return randomString

exports.Range =
  until: (minInclusive, maxExclusive) ->
    return [minInclusive..maxExclusive-1]





