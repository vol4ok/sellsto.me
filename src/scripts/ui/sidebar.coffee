#require ui/base

namespace "sm.ui", (exports) ->
  
  {ui} = sm
  {UIView, UIItem, UIClickableItem} = ui
    
  class UISidebar extends UIView
    initialize: (options) ->
      super(options)
      @items = {}
      @count = 0
      @state.current = null
      @contentView = $(@el).data('content-view')
      @_initItems()
    switch: (id) ->
      if @state.current != id
        @items[@state.current].deselect() if @state.current?
        @state.current = id
        @items[id].select()
    _initItems: ->
      $(@el).children().each (i, _el) =>
        el = $(_el)
        item = new ui[el.data('class')](el: _el, order: @count)
        @items[item.cid] = item
        @items[@count]   = item
        @count++
        _.defer => @on_itemClick(item) if el.hasClass('selected')
        item.bind('click', @on_itemClick, this)
    on_itemClick: (item) -> 
      @trigger('click', item)
      
  class UISidebarButton extends UIClickableItem
    events:
      'click': 'on_click'
    initialize: (options = {}) ->
      super(options)
      @contentBlock = $(@el).data('content-block')
      
  class UISidebarSeparator extends UIItem
    initialize: (options) ->
      super(options)
            
  exports extends {UISidebar, UISidebarButton, UISidebarSeparator}