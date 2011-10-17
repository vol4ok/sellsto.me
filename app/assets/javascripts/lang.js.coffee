# This file contains common  functions
#todo zhugrov a - maybe it should be included by sprocket by default

@root = window

@namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top    = target
  target = target[item] or= {} for item in name.split '.'
  block target, top

implements = (classes...) ->
  for klass in classes
    # static properties
    for prop of klass
      continue if prop is 'prototype' # fix Opera bug
      @[prop] = klass[prop] 
      # prototype properties
    for prop of klass.prototype
      getter = klass::__lookupGetter__(prop)
      setter = klass::__lookupSetter__(prop)
      if getter || setter
        @::__defineGetter__(prop, getter) if getter
        @::__defineSetter__(prop, setter) if setter
      else
        @::[prop] = klass::[prop]
  return this

if Object.defineProperty
  Object.defineProperty Function.prototype, "implements", value: implements
else
  Function::implements = implements