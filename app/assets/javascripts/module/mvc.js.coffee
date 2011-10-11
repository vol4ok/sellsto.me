###
Based on Backbone.js v0.5.3 (c) 2010 Jeremy Ashkenas, DocumentCloud Inc.
###

#= require lang
#= require api

namespace "sellstome.mvc", (exports) ->
	
	{api} = sellstome

	class Events
		bind: (ev, callback, context) ->
			calls = @_callbacks or (@_callbacks = {})
			list  = calls[ev] or (calls[ev] = [])
			list.push([callback, context])
			return this

		unbind: (ev, callback) ->
			unless ev
				@_callbacks = {}
			else if (calls = @_callbacks)
				unless callback
					calls[ev] = []
				else
					list = calls[ev]
					return this unless list
					for i in [i...list.length]
						if list[i] and callback == list[i][0]
							list[i] = null
							break
	    return this

	  trigger: (eventName) ->
			both = 2
			return this unless (calls = @_callbacks)
			while (both--)
				ev = if both then eventName else 'all'
				if (list = calls[ev])
					l = list.length
					for i in [0...l]
						unless (callback = list[i])
							list.splice(i, 1)
							i--; l--
						else
							args = if both then api.slice.call(arguments, 1) else arguments
							callback[0].apply(callback[1] or this, args)
			return this
			
	exports.Events = Events