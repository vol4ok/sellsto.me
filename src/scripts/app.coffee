#require vendor/underscore
#require vendor/backbone
#require config
#require mvc
#require ctr
#require vendor/jquery.mousewheel
#require vendor/jquery.jscrollpane
#require ui/toolbar
#require ui/sidebar
#require ui/ad
#require ui/map
#require ui/modal
#require ui/controls
#require ui/popovers

namespace "sm", (exports) ->
  
  {Controller, View, Model, Collection, Router} = sm.mvc
    
  class App extends Router
    {ui, ctr, cfg} = sm
    
    routes:
      '*path': 'routeTo'
    bindings:
      'search-block:show': 'search:select'
    controllers: 
      'ad-list-controller': 
        class: 'AdListCtr'
        options: {}
      'search-controller': 
        class: 'SearchCtr'
        options: {}
      'new-ad-controller': 
        class: 'ModalCtr'
        options: {modal: 'new-ad-modal', button: 'new-ad-button'}
      'pref-controller': 
        class: 'ModalCtr'
        options: {modal: 'pref-modal', button: 'pref-button'}
      'followers-controller': 
        class: 'ModalCtr'
        options: {modal: 'followers-modal', button: 'followers-button'}
        
    initialize: (options = {}) ->
      @cid = 'app'
      super(options)
      root.$app = this
      $(document).ready(_.bind(@on_domLoaded, this))
      @_initControllers()
      
    routeTo: (path) ->
      console.log path
      
    makeBinding: (trg, src) ->
      [srcId, event]  = src.split(':')
      [trgId, method] = trg.split(':')
      $$(srcId).bind(event, $$(trgId)[method], $$(trgId))
      
    expandApiURL: (relativePath) ->
    	throw new Error("Invalid argument") if not _.isString( relativePath )
    	relativePath = "/" + relativePath if relativePath.indexOf("/") != 0
    	expandedPath = "#{window.location.protocol}//#{cfg.API_HOSTNAME}#{relativePath}"
    	return expandedPath
      
    _initBindings: ->
      _.each(@bindings, @makeBinding)
    
    _initControllers: ->
      _.each @controllers, (ctx, id) =>
        ctx.options.cid = id
        new ctr[ctx.class](ctx.options)
      
    _initAutoloadClasses: ->
      $('.autoload').each (i, _el) =>
        try
          el = $(_el)
          el.removeClass('autoload')
          new ui[el.data('class')](el: _el)
        catch exc
          id          = if _el.id? then _el.id else 'undefined'
          data_class  = if _el['data-class']? then _el['data-class'] else 'undefined'
          console.error("Could not initialize a view with class: #{data_class} and id: #{id}. " + exc.toString())
        return
          
    on_domLoaded: ->
      @_initAutoloadClasses()
      @_initBindings()
      @toolbar = $$('toolbar')
      @sidebar = $$('sidebar')
      @content = $$('content-view')
      # notify controllers
      @trigger('views-loaded')
      #2DO init tips on theirs views
      #$("[rel=twipsy]").twipsy(live: true, trigger: 'hover') 
      $("[rel=UITooltip]").each (i,v) ->
        new ui.UITooltip target: v
      $("[rel=UIPopover]").each (i,v) ->
        new ui.UIPopover target: v, template: $(v).data('popover')
      
  exports.App = App

new sm.App
Backbone.history.start(pushState: yes);