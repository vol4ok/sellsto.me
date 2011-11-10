#require ui/base

namespace "sm.ui", (exports) ->
  
  {ui} = sm
  {UIView, UIItem, ISelectableItem, UISidebar} = ui
  
  class UIAdEntry extends UIView
    tagName: 'li'
    initialize: (options) ->
      super(options)
      $(@el).html( getTemplate('UIAdEntry', @model.toJSON()) )
    render: -> @el
    
  class UISpinner extends UIView
    tagName: 'li'
    className: 'spinner'
    initialize: (options) ->
      super(options)
      $(@el).html(getTemplate('UISpinner'))
    render: -> @el
      
  class UIAdList extends UISidebar
    initialize: (options = {}) ->
      super(options)
      @collection = options.collection
      @template = options.template
    showSpinner: ->
      @spinner = new UISpinner unless @spinner?
      $(@el).html(@spinner.render())
    hideSpinner: ->
      @$('.spinner').fadeOut 150, (e) -> $(this).remove()
    render: (collection) ->
      @collection = collection if collection?
      return unless @collection?
      @collection.each (model) =>
        view = new UIAdEntry(model: model)
        console.log view, model
        $(@el).append(view.render())
    
      
  exports extends {UIAdList}