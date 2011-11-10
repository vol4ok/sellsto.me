#require ui/base

namespace "sm.ui", (exports) ->
  
  {ui} = sm
  {UIView, UIItem, ISelectableItem} = ui
    
  class UIToolbar extends UIView
    initialize: (options) -> 
      super(options)
      @items = {}
      @count = 0
      @state.current = null
      @_initItems()      
    switch: (id) ->
      @items[@state.current].deselect() if @state.current?
      if @state.current != id
        @state.current = id
        @items[id].select()
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
        item.bind('select', @on_itemSelect, this)
    on_itemSelect: (item) ->
      @trigger('select', item)
      
  class UIToolbarButton extends UIItem
    @implements ISelectableItem
    events:
      'click': 'on_select'
    initialize: (options) ->
      super(options)
      
  class UIToolbarSearch extends UIItem
    events:
      'click .search-button': 'on_select'
    initialize: (options) ->
      super(options)
      @query = ''
      @input = $('.search-input')
    on_select: ->
      @query = @input.val()
      @trigger('select', this)
    select: ->
    deselect: ->
      
  class UIToolbarSeparator extends UIItem
    initialize: (options) ->
      super(options)
      
  class UIToolbarLogo extends UIItem
    initialize: (options) ->
      super(options)
    
  exports extends {UIToolbar, UIToolbarButton, UIToolbarSearch, UIToolbarSeparator, UIToolbarLogo}