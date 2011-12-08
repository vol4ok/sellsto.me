window.root = window

__ns = root.namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top = target
  target = target[item] or= {} for item in name.split '.'
  block target, top
 
implements = (classes...) ->
  for klass in classes
    # static properties
    for prop of klass
      continue if prop is 'prototype' # fix Opera bug
      @[prop] = klass[prop] 
      # prototype properties
    # for prop of klass.prototype
    #    getter = klass::__lookupGetter__(prop)
    #    setter = klass::__lookupSetter__(prop)
    #    if getter || setter
    #      @::__defineGetter__(prop, getter) if getter
    #      @::__defineSetter__(prop, setter) if setter
    #    else
    #      @::[prop] = klass::[prop]
    for prop of klass.prototype
      @::[prop] = klass::[prop]
  return this

if Object.defineProperty
  Object.defineProperty Function.prototype, "implements", value: implements
else
  Function::implements = implements
  
root.$__objects = {}
root.registerObject = (id, object) -> $__objects[id] = object
root.$$ = root.getObjectById = (id) -> $__objects[id]
root.getTemplate = (klass,data) -> 
  if arguments.length == 1
    $__templates[klass]
  else
    $__templates[klass](data)
    
SERVER_HOSTNAME = 'localhost' #window.location.hostname
REQUEST_PROTOCOL = window.location.protocol
API_SERVER_HOSTNAME = SERVER_HOSTNAME
API_PORT = 4000

expandApiURL = (relativePath) ->
	throw new Error("Invalid argument") if not _.isString( relativePath )
	relativePath = "/" + relativePath if relativePath.indexOf("/") != 0
	expandedPath = REQUEST_PROTOCOL + "//" + API_SERVER_HOSTNAME + ":" + API_PORT + relativePath
	return expandedPath
  