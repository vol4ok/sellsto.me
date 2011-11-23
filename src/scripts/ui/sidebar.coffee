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
        if el.hasClass('selected')
          @state.current = item.cid
          _.defer => @on_itemClick(item) 
        item.bind('click', @on_itemClick, this)
        item.bind('select', @on_itemSelect, this)
        item.bind('deselect', @on_itemDeselect, this)
    on_itemClick: (item) -> 
      @trigger('click', item)
    on_itemSelect: (item) ->
      if not @lock and @state.current != item.cid
        @lock = on
        @items[@state.current].deselect(yes) if @state.current?
        @lock = off
        @state.current = item.cid
      @trigger('select', item)
    on_itemDeselect: (item) ->
      if not @lock and @state.current == item.cid
        @lock = on
        item.deselect(yes)
        @lock = off
      @trigger('deselect', item)
      
      
  class UISidebarButton extends UIClickableItem
    events:
      'click': 'on_click'
    initialize: (options = {}) ->
      super(options)
      @contentBlock = $(@el).data('content-block')
      $app.bind('views-loaded', @on_viewsLoaded, this)
    on_viewsLoaded: ->
      $$(@contentBlock).bind('show', @select, this)
      
  class UISidebarSeparator extends UIItem
    initialize: (options) ->
      super(options)
            
  exports extends {UISidebar, UISidebarButton, UISidebarSeparator}