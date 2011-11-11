#require ui/base

namespace "sm.ui", (exports) ->
  
  {ui} = sm
  {UIView, UIItem, UIClickableItem} = ui
    
  class UIToolbar extends UIView
    initialize: (options) -> 
      super(options)
      @items = {}
      @count = 0
      @state.current = null
      @_initItems()      
    switch: (id) ->
      @items[@state.current].deselect() if @state.current?
      if @state.current != id and id?
        @state.current = id
        item = @items[id].select()
      else
        @state.current = null
    _initItems: ->
      $(@el).children().each (i, _el) =>
        el = $(_el)
        item = new ui[el.data('class')](el: _el, order: @count)
        @items[item.cid] = item
        @items[@count]   = item
        @count++
        @on_itemSelect(item) if el.hasClass('selected')
        item.bind('click', @on_itemClick, this)
    on_itemClick: (item) ->
      @trigger('click', item)
      
  class UIToolbarButton extends UIClickableItem
    events:
      'click': 'on_click'
    initialize: (options) ->
      super(options)
      
  class UIToolbarSearch extends UIItem
    events:
      'click .search-button': 'on_click'
    initialize: (options) ->
      super(options)
      @query = ''
      @input = $('.search-input')
      @event = $(@el).data('event') || null
      console.log @event
    on_click: ->
      @query = @input.val()
      @trigger('click', this)
    select: ->
    deselect: ->
      
  class UIToolbarSeparator extends UIItem
    initialize: (options) ->
      super(options)
      
  class UIToolbarLogo extends UIItem
    initialize: (options) ->
      super(options)
    
  exports extends {UIToolbar, UIToolbarButton, UIToolbarSearch, UIToolbarSeparator, UIToolbarLogo}