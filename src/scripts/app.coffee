#require vendor/underscore
#require vendor/backbone
#require cfg
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
      
    _initBindings: ->
      _.each(@bindings, @makeBinding)
    
    _initControllers: ->
      _.each @controllers, (ctx, id) =>
        ctx.options.cid = id
        new ctr[ctx.class](ctx.options)
      
    _initAutoloadClasses: ->
      $('.autoload').each (i, _el) =>
        el = $(_el)
        el.removeClass('autoload')
        console.log new ui[el.data('class')](el: _el)
          
    _initGoogleMaps: ->
      root.__initialize_maps = _.bind(@_initGoogleMapsCompletion, this)
      $.getScript "#{cfg.GMAP_JS_URL}&callback=__initialize_maps", (data,status) =>
        throw 'google map load failed' unless status is 'success'
        
    _initGoogleMapsCompletion: ->
      delete root.__initialize_maps
      @trigger('gmap-load', google.maps)
      
    on_domLoaded: ->
      @_initAutoloadClasses()
      @_initBindings()
      @_initGoogleMaps()
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