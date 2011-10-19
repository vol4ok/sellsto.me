#= require lang
#= require jquery
#= require module/ui/base

namespace "sellstome.ui", (exports) ->
  
  {ui} = sellstome
  {UIView, UIItem, ISelectableItem} = sellstome.ui
  
  class UITabItem extends UIItem
      
  class UITabButton extends UIItem
    @implements ISelectableItem
    initialize: (options) ->
      super(options)
      @blockCid = options.data.block
      console.log 'blockCid', @blockCid
    events:
      'click': 'on_select'
      
  class UITabPane extends UIView
    items: {}
    initialize: (options) ->
      super(options)
      @_avatorEl = @$('.avator')
      @_itemsEl = @$('.items')
      @_initAvator() if @_avatorEl.data('class')?
      @_initItems()
    setAvator: (avator) ->
      @_avatorEl.html(avator.render())
    addItem: (item) ->
      @items[item.cid] = item
      @_itemsEl.append(item.render())      
    switch: (item) ->
      if @currentCid != item.cid
        @items[@currentCid].deselect() if @currentCid?
        @currentCid = item.cid
        item.select()
    _initAvator: ->
      @avator = new ui[@_avatorEl.data('class')](el: @_avatorEl.get(0))
    _initItems: ->
      @_itemsEl.children().each (i, _el) =>
        el = $(_el)
        item = new ui[el.data('class')](el: _el, data: el.data())
        @items[item.cid] = item
        @currentCid = item.cid if el.hasClass('selected')
        item.bind('select', @on_itemSelect, this)
    on_itemSelect: (item) ->
      #@switch(item)
      @trigger('select', item)
      console.log 'select', item
      
  class UIAvator extends UIItem
    initialize: (options) ->
      super(options)
      unless options.el
        @el.html @make 'img',
          src: options.url
          alt: options.alt
        
  exports extends {UITabItem, UITabButton, UITabPane, UIAvator}