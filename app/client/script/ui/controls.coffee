#require ui/base

namespace "sm.ui", (exports) ->
  
  {ui} = sm
  {UIView, UIItem, UIClickableItem} = ui
  
  class UISelectBox extends UIView
    events: 
      'change select': 'on_selectChange'
    initialize: (options) ->
      super(options)
      @select = @$('select')
      @value = @$('span')
      @value.text(@$("option:selected").text())
    disable: ->
      $(@el).addClass('disabled')
    enable: ->
      $(@el).removeClass('enabled')
    on_selectChange: (e) ->
      @value.text(@$("option:selected").text())
      
  class UICheckbox extends UIView
    events: 
      'click': "on_click"
      'keydown': 'on_keydown'
      'focus': 'on_focus'
      'blur': 'on_blur'
    initialize: (options) ->
      @input = @$('input')
      @state = 
        disabled: $(@el).hasClass('disabled')
        checked: $(@el).hasClass('on')
    enable: ->
      @state.disabled = $(@el).addClass('disabled')
    disable: ->
      @state.disabled = $(@el).removeClass('disabled')
    on_click: ->
      return if @state.disabled
      $(@el).toggleClass('on')
      @state.checked = $(@el).hasClass('on')
      @input.attr('checked', @state.checked)
      @trigger('click', this)
      @trigger('check', this) if @state.checked
    on_focus: -> @trigger('focus', this) unless @state.disabled
    on_blur: -> @trigger('blur', this) unless @state.disabled
    on_keydown: (e) ->
      return if @state.disabled
      if e.keyCode == 13 or e.keyCode == 32
        @on_click()
      if e.keyCode == 37
        @on_click() if $(@el).hasClass('on')
      if e.keyCode == 39
        @on_click() unless $(@el).hasClass('on')
      # else if e.keyCode == 38
      #   $(@el).prev().focus()
      # else if e.keyCode == 40
      #   $(@el).next().focus()

  class UIButton extends UIView
    events: 
      'click': "on_click"
      'keydown': 'on_keydown'
      'keyup': 'on_keyup'
      # 'focus': 'on_focus'
      # 'blur': 'on_blur'
      # 'mousedown': 'on_mousedown'
      # 'mouseup': 'on_mouseup'
    initialize: (options) ->
      @state = {}
    enable: ->
      @state.disabled = no
      $(@el).removeClass('disabled')
    disable: ->
      @state.disabled = yes
      $(@el).addClass('disabled')
    on_click: ->
      return if @state.disabled
      @trigger('click', this)
    on_focus: -> @trigger('focus', this) unless @state.disabled
    on_blur: -> @trigger('blur', this) unless @state.disabled
    on_keydown: (e) ->
      console.log e.keyCode
      return if @state.disabled
      if e.keyCode == 13 or e.keyCode == 32
        $(@el).addClass('active')
    on_keyup: (e) ->
      console.log e.keyCode
      return if @state.disabled
      if e.keyCode == 13 or e.keyCode == 32
        $(@el).removeClass('active')
      
  exports extends {UISelectBox, UIButton, UICheckbox}