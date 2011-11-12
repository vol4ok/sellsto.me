#require underscore
#require ui/base

namespace "sm.ui", (exports) ->
  
  {ui} = sm
  {UIView} = ui
    
  class UIModal extends UIView
    initialize: (options) ->
      super(options)
    show: ->
      console.log 'show modal'
      @trigger('show', this)
      $(@el).fadeIn(150)
    hide: ->
      @trigger('hide',this)
      $(@el).fadeOut(150)
      
  class UINewAdModal extends UIModal
    events:
      'click .close': 'on_close'
    initialize: (options) ->
      super(options)
    on_close: ->
      @trigger('close', this)
      return false
      
  class UIModalUnderlay extends UIView
    events: 
      'click': 'on_click'
    initialize: (options) ->
      super(options)
    show: ->
      $(@el).fadeIn(200)
    hide: ->
      $(@el).fadeOut(200)
    on_click: ->
      @trigger('click', this)
          
  exports extends {UIModal, UINewAdModal, UIModalUnderlay}