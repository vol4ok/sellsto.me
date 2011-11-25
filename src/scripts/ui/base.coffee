#require backbone
#require mvc

namespace "sm.ui", (exports) ->
  
  {ui} = sm
  {Controller, View, Model, Collection, Router} = sm.mvc
      
  class UIView extends View
    initialize: (options) ->
      @state = {}
      @cid = $(@el).attr('id') if $(@el).attr('id')?
      super(options)
      
  class UIItem extends UIView
    index: null
    initialize: (options = {}) ->
      super(options)
      @index = options.index if options.index
      
  class UIClickableItem extends UIItem
    initialize: (options) ->
      super(options)    
      #check — is selected?
      if $(@el).hasClass('selected') 
        _.defer =>
          @state.selected = yes 
          @trigger('select', this) 
      else @state.selected = no
      #check — is disabled?
      if $(@el).hasClass('disabled') 
        _.defer =>
          @state.disabled = yes
          @trigger('disable', this)
      else @state.disabled = no
    select: ->
      $(@el).addClass('selected')
      @state.selected = yes
      @trigger('select', this) 
    deselect: (silent = no) ->
      $(@el).removeClass('selected')
      @state.selected = no
      @trigger('deselect', this)
    disable: ->
      $(@el).addClass('disabled')
      @state.disabled = yes
      @trigger('disable', this)
    enable: ->
      $(@el).removeClass('disabled')
      @state.disabled = no
      @trigger('enable', this)
    on_click: ->
      return if @state.disabled
      @trigger('click', this)
    on_mouseenter: ->
      return if @state.disabled
      $(@el).addClass('hover')
      @state.hover = yes
      @trigger('enter', this)
    on_mouseleave: ->
      return if @state.disabled
      $(@el).removeClass('hover')
      @state.selected = no
      @trigger('leave', this)
    
  class UIItemList extends UIView
    initialize: (options) ->
      super(options)
      @itemsByCid = {}
      @itemsByOrder = {}
      @count = 0
      @_initItems()
    _initItems: ->
      $(@el).children().each (i, _el) =>
        el = $(_el)
        item = new ui[el.data('class')](el: _el, order: @count)
        @itemsByCid[item.cid] = item
        @itemsByOrder[@count] = item
        @count++
        item.bind('click',    @on_itemClick,    this)
        item.bind('select',   @on_itemSelect,   this)
        item.bind('deselect', @on_itemDeselect, this)
        item.bind('disable',  @on_itemDisable,  this)
        item.bind('enable',   @on_itemEnable,   this)
        item.bind('enter',    @on_itemEnter,    this)
        item.bind('leave',    @on_itemLeave,    this)
    addItem: (item) ->
      #2DO
    removeItem: (id) ->
      #2DO
    hasItem: (id) ->
      #2DO
    on_itemClick:    (item) -> @trigger('click',    item)
    on_itemSelect:   (item) -> @trigger('select',   item)
    on_itemDeselect: (item) -> @trigger('deselect', item)
    on_itemDisable:  (item) -> @trigger('disable',  item)
    on_itemEnable:   (item) -> @trigger('enable',   item)
    on_itemEnter:    (item) -> @trigger('enter',    item)
    on_itemLeave:    (item) -> @trigger('leave',    item)
    
  exports extends {UIView, UIItem, UIClickableItem, UIItemList}