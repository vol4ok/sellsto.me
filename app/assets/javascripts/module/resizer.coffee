#= require jquery
#= require jquery.ui.core
#= require jquery.ui.widget
#= require jquery.ui.mouse

$.widget "custom.resizer", $.ui.mouse,
  options:
    target: null
    offset: 0
  _create: ->
    @_mouseInit()
    @offset = @options.offset
    @innerOffset = @options.width >> 1
    @element.css
      left: @offset - @innerOffset
      width: @options.width
  destroy: ->
    #todo:
  _mouseCapture: (e) ->
    @element.css(opacity: 0.8)
    @currentX = e.pageX
    return true
  _mouseDrag: (e) ->
    offset = @offset + (e.pageX - @currentX)
    @offset = @options.validate(offset)
    if offset == @offset 
      @currentX = e.pageX
    @element.css(left: @offset - @innerOffset)
  _mouseStop: (e) ->
    @element.css(opacity: 0.0)
    @_trigger('-resize', this, @offset)
  _setOption: (key, value) ->
    console.log '_setOption', key, value
    if key is 'offset'
      @offset = value
      @element.css(left: @offset - @innerOffset)