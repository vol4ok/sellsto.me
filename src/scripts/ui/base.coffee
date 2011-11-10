#require backbone
#require mvc

namespace "sm.ui", (exports) ->
  
  {Controller, View, Model, Collection, Router} = sm.mvc

  class ISelectableItem
    select: ->
      $(@el).addClass('selected')
    deselect: ->
      $(@el).removeClass('selected')
    on_select: ->
      @trigger('select', this)
      
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
    
  exports extends {ISelectableItem, UIView, UIItem}