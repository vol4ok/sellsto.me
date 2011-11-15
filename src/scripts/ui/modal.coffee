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
    MESSAGE_LENGTH = 400
    events:
      'click .close': 'on_close'
      'keyup .message': 'on_keyup'
      'keydown': 'on_keydown'
    initialize: (options) ->
      super(options)
      @messageInput = @$('.message')
      @counterEl    = @$('.counter')
      @submitButton = @$('.submit')
    on_close: ->
      @trigger('close', this)
      return false
    on_submit: ->
      @trigger('submit', this)
      return false
    on_keydown: (e) ->
      result = false;
      if e.keyCode is 27 then @on_close()
      else if e.keyCode is 13 and e.shiftKey then @on_submit()
      else result = true
      return result
    on_keyup: (e) ->
      len = @messageInput.val().length
      @counterEl.html(MESSAGE_LENGTH - len)
      if len is 0 or len > 400
        @submitButton.addClass('disabled')
      else
        @submitButton.removeClass('disabled')
      return true
      
  class UIModalUnderlay extends UIView
    events: 
      "click": "on_click"
    initialize: (options) ->
      super(options)
    show: ->
      $(@el).fadeIn(200)
    hide: ->
      $(@el).fadeOut(200)
    on_click: ->
      @trigger('click', this)
          
  exports extends {UIModal, UINewAdModal, UIModalUnderlay}