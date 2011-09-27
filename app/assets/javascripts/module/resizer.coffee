#= require jquery
#= require jquery.ui.core
#= require jquery.ui.widget
#= require jquery.ui.mouse

$.widget "custom.resizer", $.ui.mouse,
	options:
		#todo: add options for min and max size
		target: null
	_create: ->
		@_mouseInit();
	destroy: ->
		#todo: 
	_mouseCapture: (e) ->
		return true
	_mouseDrag: (e) ->
		#todo: calc relative size
		@options.target.width(e.pageX)