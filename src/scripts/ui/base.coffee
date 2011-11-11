#require backbone
#require mvc

namespace "sm.ui", (exports) ->
  
  {Controller, View, Model, Collection, Router} = sm.mvc
      
  class UIView extends View
    initialize: (options) ->
      @state = {}
      @cid = $(@el).attr('id') if $(@el).attr('id')?
      super(options)
      
  class UIItem extends UIView
    order: null
    initialize: (options = {}) ->
      super(options)
      @order = options.order if options.order
      $(@el).css(float: 'right') if options.right
      
  class UIClickableItem extends UIItem
    initialize: (options) ->
      super(options)
    select: ->
      $(@el).addClass('selected')
      @state.selected = yes
      @trigger('select', this)
    deselect: ->
      $(@el).removeClass('selected')
      @state.selected = no
      @trigger('deselect', this)
    on_click: ->
      @trigger('click', this)
    
  exports extends {UIView, UIItem, UIClickableItem}