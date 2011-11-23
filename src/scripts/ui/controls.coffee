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
      
  exports extends {UISelectBox}