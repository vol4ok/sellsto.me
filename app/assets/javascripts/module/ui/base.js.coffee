#= require lang
#= require jquery

namespace "sellstome.ui", (exports) ->
  
  class ISelectableItem
    select: ->
      $(@el).addClass('selected')
    deselect: ->
      $(@el).removeClass('selected')
    on_select: ->
      console.log 'on_select'
      @trigger('select', this)
      
  class UIView extends Backbone.View
    initialize: ->
      @cid = $(@el).attr('id') if $(@el).attr('id')?
      $views[@cid] = this
  
  class UIItem extends UIView
    tagName: 'li'
    initialize: (options) ->
      super(options)
      $(@el).html(options.template()) if options.template?
    render: -> @el
    
    
  class UIContentBlock extends UIView
    initialize: (options) ->
      super(options)
      $(@el).html(options.template())
    render: -> @el
    show: -> $(@el).show()
    hide: -> $(@el).hide()

  class UIContentView extends UIView
    blocks: {}
    initialize: (options) ->
      super(options)
    addBlock: (block) ->
      @blocks[block.cid] = block
    switch: (cid) ->
      console.log 'switch', cid
      $(@el).html(@blocks[cid].render())
    
  exports extends {ISelectableItem, UIItem, UIView}
  exports extends {UIContentBlock, UIContentView}