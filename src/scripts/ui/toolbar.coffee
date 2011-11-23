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
      @items[@state.current].deselect(silent: yes) if @state.current?
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
      
  class UIToolbarButton extends UIClickableItem
    events:
      'click': 'on_click'
    initialize: (options) ->
      super(options)
      
  class UIToolbarSearch extends UIItem
    events:
      'click .search-button': 'on_click'
      'keydown .search-input': 'on_keydown'
      'keyup .search-input': 'on_keyup'
    initialize: (options) ->
      super(options)
      @query = ''
      @input = $('.search-input')
      @button = $('.search-button')
    #2DO: refactor with finstal state machine
    on_click: ->
      @query = @input.val()
      return false if @query.length == 0
      @trigger('click', this)
      @trigger('search', @query)
      @button.removeClass('glow')
      return false
    on_keydown: (e) ->
      if @input.val().length == 0
        @button.addClass('disabled')
        @button.removeClass('glow')
      else
        @button.removeClass('disabled')
        @button.addClass('glow')
      if e.keyCode is 13
        @on_click()
        return false
      else 
        return true
    on_keyup: (e) ->
    # override methods
    select: ->
    deselect: ->
      
  class UIToolbarSeparator extends UIItem
    initialize: (options) ->
      super(options)
      
  class UIToolbarLogo extends UIItem
    initialize: (options) ->
      super(options)
    
  exports extends {UIToolbar, UIToolbarButton, UIToolbarSearch, UIToolbarSeparator, UIToolbarLogo}