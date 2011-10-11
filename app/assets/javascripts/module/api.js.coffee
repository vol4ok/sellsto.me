###
Based on Underscore.js v1.1.7 (c) 2011 Jeremy Ashkenas, DocumentCloud Inc.
###
#= require lang

namespace "sellstome.api", (exports) ->

  # Establish the object that gets returned to break out of a loop iteration.
  breaker = {}

  ArrayProto = Array.prototype
  ObjProto   = Object.prototype
  FuncProto  = Function.prototype

  {slice,unshift}           = ArrayProto
  {toString,hasOwnProperty} = ObjProto

  # All **ECMAScript 5** native function implementations that we hope to use
  # are declared here.
  nativeForEach      = ArrayProto.forEach
  nativeMap          = ArrayProto.map
  nativeReduce       = ArrayProto.reduce
  nativeReduceRight  = ArrayProto.reduceRight
  nativeFilter       = ArrayProto.filter
  nativeEvery        = ArrayProto.every
  nativeSome         = ArrayProto.some
  nativeIndexOf      = ArrayProto.indexOf
  nativeLastIndexOf  = ArrayProto.lastIndexOf
  nativeIsArray      = Array.isArray
  nativeKeys         = Object.keys
  nativeBind         = FuncProto.bind

  # By default, Underscore uses ERB-style template delimiters, change the
  # following template settings to use alternative delimiters.
  templateSettings = 
    evaluate: /<%([\s\S]+?)%>/g
    interpolate: /<%=([\s\S]+?)%>/g
    escape: /<%-([\s\S]+?)%>/g

  
  ###----[ COLLECTIONS ]----###

  
  each = forEach = (obj, iterator, context) ->
    return unless obj?
    if nativeForEach and obj.forEach == nativeForEach
      obj.forEach(iterator, context);
    else if obj.length == +obj.length
      for i in [0...obj.length]
        return if i of obj and iterator.call(context, obj[i], i, obj) == breaker
    else
      for own key, val of obj
        return if iterator.call(context, obj[key], key, obj) == breaker

  map = (obj, iterator, context) ->
    results = []
    return results if obj is null
    return obj.map(iterator, context) if nativeMap and obj.map == nativeMap
    each obj, (value, index, list) ->
      results[results.length] = iterator.call(context, value, index, list)
    return results
    
  reduce = foldl = inject = (obj, iterator, memo, context) ->
    initial = memo != undefined
    obj = [] unless obj?
    if nativeReduce and obj.reduce == nativeReduce
      iterator = bind(iterator, context) if context
      return (if initial then obj.reduce(iterator, memo) else obj.reduce(iterator))
    each obj, (value, index, list) ->
      unless initial
        memo = value
        initial = true
      else
        memo = iterator.call(context, memo, value, index, list)
    throw new TypeError("Reduce of empty array with no initial value") unless initial
    return memo
    
  reduceRight = foldr = (obj, iterator, memo, context) ->
    obj = [] unless obj?
    if nativeReduceRight and obj.reduceRight == nativeReduceRight
      iterator = bind(iterator, context) if context
      return (if memo != undefined then obj.reduceRight(iterator, memo) else obj.reduceRight(iterator))
    reversed = (if isArray(obj) then obj.slice() else _.toArray(obj)).reverse()
    return reduce reversed, iterator, memo, context
    
  find = detect = (obj, iterator, context) ->
    result = false
    any obj, (value, index, list) ->
      if iterator.call(context, value, index, list)
        result = value
        return true
    return result

  filter = select = (obj, iterator, context) ->
    results = []
    return results unless obj?
    return obj.filter(iterator, context) if nativeFilter and obj.filter == nativeFilter
    each obj, (value, index, list) ->
      results[results.length] = value if iterator.call(context, value, index, list)
    return results

  reject = (obj, iterator, context) ->
    results = []
    return results unless obj?
    each obj, (value, index, list) ->
      results[results.length] = value unless iterator.call(context, value, index, list)
    return results

  every = all = (obj, iterator, context) ->
    result = true
    return result unless obj?
    return obj.every(iterator, context) if nativeEvery and obj.every == nativeEvery
    each obj, (value, index, list) ->
      breaker unless (result = result and iterator.call(context, value, index, list))
    return result
    
  any = some = (obj, iterator, context) ->
    iterator or= identity
    result = false
    return result if obj is null
    return obj.some(iterator, context) if nativeSome and obj.some is nativeSome
    each obj, (value, index, list) -> 
      breaker if result or= iterator.call(context, value, index, list)
    return !!result

  include = contains = (obj, target) ->
    found = false
    return found if obj is null
    obj.indexOf(target) != -1 if nativeIndexOf and obj.indexOf == nativeIndexOf
    any obj, (value) ->
      return true if (found = value) == target
    return found

  invoke = (obj, method) ->
    args = slice.call(arguments, 2)
    map obj, (value) ->
      (if method.call then method or value else value[method]).apply value, args

  pluck = (obj, key) ->
    map obj, (value) -> value[key]

  max = (obj, iterator, context) ->
    return Math.max.apply(Math, obj) if not iterator and isArray(obj)
    result = computed: -Infinity
    each obj, (value, index, list) ->
      computed = if iterator then iterator.call(context, value, index, list) else value
      computed >= result.computed and (result = {value: value, computed: computed})
    return result.value

  min = (obj, iterator, context) ->
    return Math.min.apply(Math, obj) if not iterator and isArray(obj)
    result = computed: Infinity
    each obj, (value, index, list) ->
      computed = if iterator then iterator.call(context, value, index, list) else value
      computed < result.computed and (result = {value: value, computed: computed})
    return result.value
    
  shuffle = (obj) ->
    shuffled = []
    each obj, (value, index, list) ->
      if index is 0
        shuffled[0] = value
      else
        rand = Math.floor(Math.random() * (index + 1))
        shuffled[index] = shuffled[rand]
        shuffled[rand] = value
    return shuffled

  sortBy = (obj, iterator, context) ->
    return pluck(((map obj, (value, index, list) ->
      {value: value, criteria: iterator.call(context, value, index, list)}
    ).sort((left, right) ->
      a = left.criteria; b = right.criteria
      if a < b then -1 else if a > b then 1 else 0
    )), 'value')

  groupBy = (obj, iterator) ->
    result = {}
    each obj, (value, index) ->
      key = iterator(value, index)
      (result[key] or (result[key] = [])).push(value)
    return result

  sortedIndex = (array, obj, iterator) ->
    iterator or (iterator = identity)
    low = 0; high = array.length
    while low < high
      mid = (low + high) >> 1
      (if iterator(array[mid]) < iterator(obj) then low = mid + 1 else high = mid)
    return low

  toArray = (iterable) ->
    return [] unless iterable
    return iterable.toArray() if iterable.toArray
    return slice.call(iterable) if isArray(iterable)
    return slice.call(iterable) if isArguments(iterable)
    return values(iterable)

  size = (obj) -> toArray(obj).length

  ###----[ ARRAYS ]----###

  first = head = (array, n, guard) ->
    return (if (n isnt null) and not guard then slice.call(array, 0, n) else array[0])

  rest = tail = (array, index, guard) ->
    slice.call(array, (index is null) or if guard then 1 else index)

  last = (array, n, guard) ->
    return (if (n?) and not guard then slice.call(array, array.length - n) else array[array.length - 1])

  compact = (array) -> filter(array, (value) -> !!value)

  flatten = (array) ->
    return reduce array, (memo, value) ->
      return memo.concat(flatten(value)) if isArray(value)
      memo[memo.length] = value
      return memo
    , []

  without = (array) -> difference(array, slice.call(arguments, 1))

  uniq = unique = (array, isSorted) ->
    return reduce array, (memo, el, i) ->
      memo[memo.length] = el if 0 is i or (if isSorted is true then last(memo) isnt el else not include(memo, el))
      return memo
    , []
    
  uniq = unique = (array, isSorted, iterator) ->
    initial = (if iterator then _.map(array, iterator) else array)
    result = []
    reduce initial, (memo, el, i) ->
      if 0 == i or (if isSorted == true then last(memo) != el else not include(memo, el))
        memo[memo.length] = el
        result[result.length] = array[i]
      return memo
    , []
    return result

  union = -> uniq(flatten(arguments))

  intersection = intersect = (array) ->
    rest = slice.call(arguments, 1)
    filter _.uniq(array), (item) ->
      every rest, (other) ->
        indexOf(other, item) >= 0

  difference = (array, other) -> filter array, (value) -> !include(other, value)

  zip = ->
    args = slice.call(arguments)
    length = max(pluck(args, "length"))
    results = new Array(length)
    results[i] = pluck(args, "" + i) for i in [0...length]
    return results

  indexOf = (array, item, isSorted) ->
    return -1 unless array?
    if isSorted
      i = sortedIndex(array, item)
      return (if array[i] == item then i else -1)
    return array.indexOf(item) if nativeIndexOf and array.indexOf == nativeIndexOf
    for i in [0...array.length]
      return i if array[i] == item
    return -1

  lastIndexOf = (array, item) ->
    return -1 unless array?
    return array.lastIndexOf(item) if nativeLastIndexOf and array.lastIndexOf == nativeLastIndexOf
    i = array.length
    while i--
      return i if array[i] == item
    return -1

  range = (start, stop, step) ->
    if arguments.length <= 1
      stop = start or 0
      start = 0
    step = arguments[2] or 1
    len = Math.max(Math.ceil((stop - start) / step), 0)
    idx = 0
    range = new Array(len)
    while idx < len
      range[idx++] = start
      start += step
    range


  ###----[ FUNCTIONS ]----###
  
  bind = (func, obj) ->
    if (func.bind == nativeBind && nativeBind) 
      return nativeBind.apply(func, slice.call(arguments, 1)) 
    args = slice.call(arguments, 2)
    return ->  return func.apply(obj, args.concat(slice.call(arguments)))

  bindAll = (obj) ->
    funcs = slice.call(arguments, 1)
    funcs = _.functions(obj) if funcs.length is 0 
    each funcs, (f) -> obj[f] = bind(obj[f], obj)
    return obj
  
  memoize = (func, hasher) ->
    memo = {}
    hasher or (hasher = identity)
    return ->
      key = hasher.apply(this, arguments)
      return (if hasOwnProperty.call(memo, key) then memo[key] else (memo[key] = func.apply(this, arguments)))

  delay = (func, wait) ->
    args = slice.call(arguments, 2)
    return setTimeout ->
      func.apply(func, args)
    , wait
    
  # TODO
  defer = (func) ->
    delay.apply(_, [ func, 1 ].concat(slice.call(arguments, 1)))

  limit = (func, wait, debounce) ->
    return ->
      context = this
      args = arguments
      throttler = ->
        timeout = null
        func.apply(context, args)
      clearTimeout(timeout if debounce)
      timeout = setTimeout(throttler, wait) if debounce or not timeout
      
  throttle = (func, wait) -> limit func, wait, false

  debounce = (func, wait) -> limit func, wait, true

  once = (func) ->
    ran = false
    return ->
      return memo if ran
      ran = true
      memo = func.apply(this, arguments)

  wrap = (func, wrapper) ->
    return ->
      args = [ func ].concat(slice.call(arguments))
      wrapper.apply this, args

  compose = ->
    funcs = slice.call(arguments)
    return ->
      args = slice.call(arguments)
      i = funcs.length - 1
      while i >= 0
        args = [ funcs[i].apply(this, args) ]
        i--
      return args[0]

  after = (times, func) -> -> func.apply(this, arguments)  if --times < 1
  
  ###----[ OBJECTS ]----###
  
  keys = nativeKeys or (obj) ->
    throw new TypeError("Invalid object")  if obj != Object(obj)
    keys = []
    for own key of obj
      keys[keys.length] = key
    return keys

  values = (obj) -> map obj, identity
  
  functions = methods = (obj) ->
    names = []
    for key of obj
      names.push(key) if isFunction(obj[key])
    return names.sort()
    
  extend = (obj) ->
    each slice.call(arguments, 1), (source) ->
      for prop of source
        obj[prop] = source[prop] if source[prop] != undefined
    return obj

  defaults = (obj) ->
    each slice.call(arguments, 1), (source) ->
      for prop of source
        obj[prop] = source[prop]  unless obj[prop]?
    return obj

  clone = (obj) -> if isArray(obj) then obj.slice() else extend({}, obj)

  tap = (obj, interceptor) ->
    interceptor(obj)
    return obj

  eq = (a, b, stack) ->
    return a != 0 or 1 / a == 1 / b  if a == b
    return a == b  unless a?
    typeA = typeof a
    return false  unless typeA == typeof b
    return false  unless not a == not b
    return isNaN(b) if isNaN(a)
    isStringA = isString(a)
    isStringB = isString(b)
    return isStringA and isStringB and String(a) == String(b)  if isStringA or isStringB
    isNumberA = isNumber(a)
    isNumberB = isNumber(b)
    return isNumberA and isNumberB and +a == +b  if isNumberA or isNumberB
    isBooleanA = isBoolean(a)
    isBooleanB = isBoolean(b)
    return isBooleanA and isBooleanB and +a == +b  if isBooleanA or isBooleanB
    isDateA = isDate(a)
    isDateB = isDate(b)
    return isDateA and isDateB and a.getTime() == b.getTime()  if isDateA or isDateB
    isRegExpA = isRegExp(a)
    isRegExpB = isRegExp(b)
    return isRegExpA and isRegExpB and a.source == b.source and a.global == b.global and a.multiline == b.multiline and a.ignoreCase == b.ignoreCase  if isRegExpA or isRegExpB
    return false  unless typeA == "object"
    a = a._wrapped  if a._chain
    b = b._wrapped  if b._chain
    return a.isEqual(b)  if _.isFunction(a.isEqual)
    length = stack.length
    while length--
      return true  if stack[length] == a
    stack.push a
    size = 0
    result = true
    if a.length == +a.length or b.length == +b.length
      size = a.length
      result = size == b.length
      if result
        while size--
          break  unless (result = size of a == size of b and eq(a[size], b[size], stack))
    else
      for own key of a
        size++
        break unless (result = hasOwnProperty.call(b, key) and eq(a[key], b[key], stack))
      if result
        for own key of b
          break unless size--
        result = not size
    stack.pop()
    return result
  isEqual = (a, b) -> eq(a, b, [])
    
  isEmpty = (obj) ->
    return obj.length is 0 if isArray(obj) or isString(obj)
    return false for own key of obj
    return true

  isElement = (obj) -> obj and obj.nodeType is 1
  
  isArray = nativeIsArray or (obj) -> 
    return !!(obj and obj.concat and obj.unshift and not obj.callee)
    
  isObject = (obj) -> obj is Object(obj)
  
  isArguments = (obj) -> obj and obj.callee
  
  isFunction = (obj) -> !!(obj and obj.constructor and obj.call and obj.apply)
  
  isString = (obj) -> !!(obj is '' or (obj and obj.charCodeAt and obj.substr))
  
  isNumber = (obj) ->
    return !!(obj == 0 or (obj and obj.toExponential and obj.toFixed))
    
  isBoolean = (obj) -> obj is true or obj is false
  
  isNaN = (obj) -> obj isnt obj
  
  isDate = (obj) -> 
    (obj) -> !!(obj and obj.getTimezoneOffset and obj.setUTCFullYear)
    
  isRegExp = (obj) -> 
    !!(obj and obj.test and obj.exec and (obj.ignoreCase or obj.ignoreCase is false))
    
  isNull = (obj) -> obj is null
  
  isUndefined = (obj) -> typeof obj is 'undefined'
  
    
  
  ###----[ UTILITY ]----###
  
  identity = (value) -> value

  times = (n, iterator, context) ->
    iterator.call(context, i) for i in [0...n]
    
  mixin = (obj) ->
    each functions(obj), (name) ->
      addToWrapper name, _[name] = obj[name]
    
  idCounter = 0;
  uniqueId = (prefix) ->
    id = idCounter++
    return if prefix then prefix + id else id

  template = (str, data) ->
    c = templateSettings
    tmpl = "var __p=[],print=function(){__p.push.apply(__p,arguments);};" + 
      "with(obj||{}){__p.push('" + 
      str.replace(/\\/g, "\\\\")
      .replace(/'/g, "\\'")
      .replace c.escape, (match, code) ->
        "',_.escape(" + code.replace(/\\'/g, "'") + "),'"
      .replace c.interpolate, (match, code) ->
        "'," + code.replace(/\\'/g, "'") + ",'"
      .replace c.evaluate or null, (match, code) ->
        "');" + code.replace(/\\'/g, "'").replace(/[\r\n\t]/g, " ") + "__p.push('"
      .replace(/\r/g, "\\r")
      .replace(/\n/g, "\\n")
      .replace(/\t/g, "\\t") + 
      "');}return __p.join('');"
    func = new Function("obj", tmpl)
    return (if data then func(data) else func)
  
  ###----[ EXPORTS ]----###
  exports extends {templateSettings, breaker}
  exports extends {slice, unshift, toString, hasOwnProperty}
  exports extends {ArrayProto, ObjProto, FuncProto}
  exports extends {each, forEach, map, bind, bindAll}