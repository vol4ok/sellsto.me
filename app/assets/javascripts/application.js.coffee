#= require lang
#= require jquery
#= require backbone
#= require backbone_ext
#= require module/resizer
#= require module/sellstome

namespace "sellstome", (exports) ->
  
  Template = (id) -> _.template($(id).html())
    
  class ISelectableItem
    select: ->
      $(@el).addClass('selected')
    deselect: ->
      $(@el).removeClass('selected')
    on_select: ->
      @trigger('select', this)
  
  class ISwitchItem
    switch: (item) ->
      @items[@currentCid].deselect() if @currentCid?
      if @currentCid != item.cid
        @currentCid = item.cid
        item.select()
      else
        @currentCid = null
  
  class UIItem extends Backbone.View
    tagName: 'li'
    initialize: (options) ->
      $(@el).html(options.template())
    render: -> @el
    
  ### TOOLBAR ###
    
  class UIToolbarItem extends UIItem
    tagName: 'li'
    initialize: (options) ->
      super(options)
      $(@el).css(float: 'right') if options.right
  
  class UIToolbarButton extends UIToolbarItem
    @implements ISelectableItem
    events:
      'click': 'on_select'
        
  class UIToolbar extends Backbone.View
    @implements ISwitchItem
    items: {}
    initialize: ->
      @_itemsEl = @$('.items')
    addItem: (item) ->
      @items[item.cid] = item
      @_itemsEl.append(item.render())
      
  ### TABPANE ###
      
  class UITabItem extends UIItem
    @implements ISelectableItem
    events:
      'click': 'on_select'
      
  class UITabPane extends Backbone.View
    @implements ISwitchItem
    items: {}
    initialize: (optinos) ->
      @_avatorEl = @$('.avator')
      @_itemsEl = @$('.items')
    setAvator: (avator) ->
      @_avatorEl.html(avator.render())
    addItem: (item) ->
      @items[item.cid] = item
      @_itemsEl.append(item.render())
      
  class UIAvator extends UIItem
    initialize: (options) ->
      @el = @make 'img',
        src: options.url
        alt: options.alt
        
  ### CONTENT BLOCK ###
    
  class UIContentBlock extends Backbone.View
    initialize: (options) ->
      $(@el).html(options.template())
    render: -> @el
    show: -> $(@el).show()
    hide: -> $(@el).hide()
      
  class UIContentView extends Backbone.View
    blocks: {}
    initialize: (options) ->
    addBlock: (block) ->
      @blocks[block.cid] = block
    switch: (cid) ->
      console.log 'switch', cid
      $(@el).html(@blocks[cid].render())
      
  ### APP ###
  
  class SellsApp extends Backbone.Router
    routes:
      '*path': 'routeTo'
    initialize: ->
      @_toolbar = new UIToolbar
        el: '#toolbar'
        
      @_tabPane = new UITabPane
        el: '#tab-pane'
        
      @_contentView = new UIContentView
        el: '#content-view'
        
      # ---> toolbar <--- #
         
      item = new UIToolbarButton
        template: Template('#new-ad-toolbar-item')
      item.bind('select', @on_toolbarItemSelect, this)
      @_toolbar.addItem(item)
      
      item = new UIToolbarItem
        template: Template('#toolbar-separator')
      item.bind('select', @on_toolbarItemSelect, this)
      @_toolbar.addItem(item)
        
      item = new UIToolbarItem
        template: Template('#search-input')
      item.bind('select', @on_toolbarItemSelect, this)
      @_toolbar.addItem(item)
      
      item = new UIToolbarButton
        template: Template('#preferences-toolbar-item')
        right: yes
      item.bind('select', @on_toolbarItemSelect, this)
      @_toolbar.addItem(item)
      
      item = new UIToolbarButton
        template: Template('#followers-toolbar-item')
        right: yes
      item.bind('select', @on_toolbarItemSelect, this)
      @_toolbar.addItem(item)
      
      # ---> tab & blocks <--- #
        
      block = new UIContentBlock
        template: Template('#list-block')
      @_contentView.addBlock(block)
      
      item = new UITabItem
        template: Template('#list-tab')
      item.blockCid = block.cid
      item.bind('select', @on_tabSelect, this)
      @_tabPane.addItem(item)
      @on_tabSelect(item)
      
      
      block = new UIContentBlock
        template: Template('#mine-block')
      @_contentView.addBlock(block)
      
      item = new UITabItem
        template: Template('#mine-tab')
      item.blockCid = block.cid
      item.bind('select', @on_tabSelect, this)
      @_tabPane.addItem(item)
      
      
      block = new UIContentBlock
        template: Template('#messages-block')
      @_contentView.addBlock(block)
      
      item = new UITabItem
        template: Template('#messages-tab')
      item.blockCid = block.cid
      item.bind('select', @on_tabSelect, this)
      @_tabPane.addItem(item)
      
      
      item = new UIItem
        template: Template('#tab-separator')
      @_tabPane.addItem(item)
      
      
      block = new UIContentBlock
        template: Template('#card-block')
      @_contentView.addBlock(block)
      
      item = new UITabItem
        template: Template('#card-tab')
      item.blockCid = block.cid
      item.bind('select', @on_tabSelect, this)
      @_tabPane.addItem(item)
      
      
      block = new UIContentBlock
        template: Template('#like-block')
      @_contentView.addBlock(block)
      
      item = new UITabItem
        template: Template('#like-tab')
      item.blockCid = block.cid
      item.bind('select', @on_tabSelect, this)
      @_tabPane.addItem(item)
      
      
      item = new UIItem
        template: Template('#tab-separator')
      @_tabPane.addItem(item)
      
      
      block = new UIContentBlock
        template: Template('#search-block')
      @_contentView.addBlock(block)
      
      item = new UITabItem
        template: Template('#search-tab')
      item.blockCid = block.cid
      item.bind('select', @on_tabSelect, this)
      @_tabPane.addItem(item)
      
      avator = new UIAvator
        url: '/assets/sample/avator.png'
        alt: 'vol4ok'
      @_tabPane.setAvator(avator)
        
    routeTo: (path) ->
      console.log 'routeTo:', path
      
    on_toolbarItemSelect: (item) ->
      @_toolbar.switch(item)
        
    on_tabSelect: (item) ->
      @_tabPane.switch(item)
      @_contentView.switch(item.blockCid)
      
  exports.App = SellsApp
  
$ () ->
  _.templateSettings = interpolate: /\{\{(.+?)\}\}/g
  $app = new sellstome.App
  Backbone.history.start(pushState: yes);