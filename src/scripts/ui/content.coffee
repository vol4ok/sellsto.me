#require ui/base

namespace "sm.ui", (exports) ->
  
  {ui} = sm
  {UIView} = ui
  
  class UIContentBlock extends UIView
    initialize: (options) ->
      super(options)
    show: (callback) -> 
      @trigger('show', this)
      $(@el).fadeIn(150, callback)
    hide: (callback) -> 
      @trigger('hide', this)
      $(@el).fadeOut(150, callback)
    
  class UIContentView extends UIView
    initialize: (options) ->
      super(options)
      @blocks = {}
      @count = 0
      @state.current = null
      @_initBlocks()
    switch: (id) ->
      if @state.current != id
        if @state.current?
          @blocks[@state.current].hide => 
            @state.current = id
            @blocks[id].show()
        else
          @state.current = id
          @blocks[id].show()
    _initBlocks: ->
      $(@el).children().each (i, _el) =>
        el = $(_el)
        block = new ui[el.data('class')](el: _el)
        @blocks[block.cid] = block
        @count++
        
  exports extends {UIContentView, UIContentBlock}