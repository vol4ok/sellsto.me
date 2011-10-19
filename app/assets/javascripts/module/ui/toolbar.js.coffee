#= require lang
#= require jquery
#= require module/ui/base

namespace "sellstome.ui", (exports) ->
  
  {ui} = sellstome
  {UIView, UIItem, ISelectableItem} = sellstome.ui
  
  class UIToolbarItem extends UIItem
    tagName: 'li'
    initialize: (options) ->
      super(options)
      $(@el).css(float: 'right') if options.right

  class UIToolbarButton extends UIToolbarItem
    @implements ISelectableItem
    events:
      'click': 'on_select'
      
  class UIToolbarSearch extends UIToolbarItem
    @implements ISelectableItem
    events:
      'click .submit': 'on_select'
    select: ->
    deselect: ->
      
  class UIToolbar extends UIView
    items: {}
    initialize: (options) ->
      super(options)
      @_itemsEl = @$('.items')
      @_initItems()
    addItem: (item) ->
      @items[item.cid] = item
      @_itemsEl.append(item.render())
    switch: (item) ->
      @items[@currentCid].deselect() if @currentCid?
      if @currentCid != item.cid
        @currentCid = item.cid
        item.select()
      else
        @currentCid = null
    _initItems: ->
      @_itemsEl.children().each (i, _el) =>
        el = $(_el)
        item = new ui[el.data('class')](el: _el)
        @items[item.cid] = item
        @currentCid = item.cid if el.hasClass('selected')
        item.bind('select', @on_itemSelect, this)
    on_itemSelect: (item) ->
      #@switch(item)
      @trigger('select', item)
      console.log 'select', item
        
  exports extends {UIToolbarItem, UIToolbarButton, UIToolbarSearch, UIToolbar}