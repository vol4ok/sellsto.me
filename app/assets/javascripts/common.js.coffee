# This file contains common  functions

window.namespace = ( name , scopedCode ) ->
  ns = name.split "."
  len = ns.length
  o = window
  for i in [0..len - 1]
    if i != len - 1
      o = o[ns[i]] = o[ns[i]] || {};
    else
      if _.isUndefined(o[ns[i]]) or _.isNull(o[ns[i]])
        o[ns[i]] = scopedCode
      else
        _.extend o[ns[i]], scopedCode