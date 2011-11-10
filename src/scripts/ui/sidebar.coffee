#require ui/base

namespace "sm.ui", (exports) ->
  
  {ui} = sm
  {UIView, UIItem, ISelectableItem} = ui
    
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
        _.defer => @on_itemSelect(item) if el.hasClass('selected')
        item.bind('select', @on_itemSelect, this)
    on_itemSelect: (item) -> 
      @trigger('select', item)
      
  class UISidebarButton extends UIItem
    @implements ISelectableItem
    events:
      'click': 'on_select'
    initialize: (options = {}) ->
      super(options)
      @contentBlock = $(@el).data('content-block')
      
  class UISidebarSeparator extends UIItem
    initialize: (options) ->
      super(options)
            
  exports extends {UISidebar, UISidebarButton, UISidebarSeparator}