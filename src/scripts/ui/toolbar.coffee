#require vendor/underscore
#require ui/base

namespace "sm.ui", (exports) ->
  
  {ui} = sm
  {UIView, UIItem, UIClickableItem, UIItemList} = ui
    
  class UIToolbar extends UIItemList
    initialize: (options) -> 
      super(options)
    deselectAll: ->
      _.each @itemsByCid, (item) -> item.deselect if item.state.selected
      
  class UIToolbarButton extends UIClickableItem
    events:
      'click': 'on_click'
      'mouseenter': 'on_mouseenter'
      'mouseleave': 'on_mouseleave'
    initialize: (options) -> super(options)
      
  class UIToolbarSearch extends UIItem
    events:
      'click .search-button': 'on_click'
      'keydown .search-input': 'on_keydown'
    initialize: (options) ->
      super(options)
      @query = ''
      @input = $('.search-input')
      @button = $('.search-button')
    #2DO: refactor with finstal state machine
    on_click: ->
      return if @state.disabled
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
    # override methods
    select: ->
    deselect: ->
      
  class UIToolbarSeparator extends UIItem
    initialize: (options) -> super(options)
      
  class UIToolbarLogo extends UIItem
    initialize: (options) -> super(options)
    
  exports extends {UIToolbar, UIToolbarButton, UIToolbarSearch, UIToolbarSeparator, UIToolbarLogo}