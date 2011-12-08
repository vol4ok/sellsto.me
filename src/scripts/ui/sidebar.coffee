#require vendor/underscore
#require ui/base

namespace "sm.ui", (exports) ->
  
  {ui} = sm
  {UIView, UIItem, UIClickableItem, UIItemList} = ui
  {Controller} = sm.mvc
    
  class UISidebar extends UIItemList
    initialize: (options) -> 
      super(options)
      @contentViewId = $(@el).data('content-view')
      
  class UISidebarButton extends UIClickableItem
    events:
      'click': 'on_click'
      'mouseenter': 'on_mouseenter'
      'mouseleave': 'on_mouseleave'
    initialize: (options = {}) ->
      super(options)
      @blockId = $(@el).data('content-block')
      $app.bind('views-loaded', @on_viewsLoaded, this)
    on_viewsLoaded: ->
      @block = $$(@blockId)
      @block.bind('show', @select, this)
      @block.bind('hide', @deselect, this)
    on_click: ->
      @block.switch()
      
  class UISidebarSeparator extends UIItem
    initialize: (options) -> super(options)
      
  class UIContentBlock extends UIView
    initialize: (options) ->
      super(options)
      @switchTimeout = options.switchTimeout || 150
      if $(@el).hasClass('default')
        _.defer => @switch()
    switch: ->
      @trigger('switch', this)
    show: (callback) -> 
      @trigger('show', this)
      $(@el).fadeIn(@switchTimeout, callback)
    hide: (callback) -> 
      @trigger('hide', this)
      $(@el).fadeOut(@switchTimeout, callback)

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
        @trigger('switch', id)
    _initBlocks: ->
      $(@el).children().each (i, _el) =>
        el = $(_el)
        block = new ui[el.data('class')](el: _el)
        @blocks[block.cid] = block
        @count++
        block.bind('switch', @on_switch, this)
        block.bind('show', @on_show, this)
        block.bind('hide', @on_hide, this)
    on_switch: (block) -> @switch(block.cid)
    on_show: (block) -> @trigger('show', block)
    on_hide: (block) -> @trigger('hide', block)
            
  exports extends {UISidebar, UISidebarButton, UISidebarSeparator, UIContentView, UIContentBlock}