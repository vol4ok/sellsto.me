#require underscore
#require backbone
#require cfg
#require mvc
#require ctr/ad-list
#require ui/toolbar
#require ui/sidebar
#require ui/content
#require ui/ad
#require ui/map

namespace "sm", (exports) ->
  
  {Controller, View, Model, Collection, Router} = sm.mvc
    
  class App extends Router
    {ui, ctr, cfg} = sm
    
    routes:
      '*path': 'routeTo'
    bindings:
      'toolbar:select': 'app:on_toolbarItemSelect'
      'sidebar:select': 'app:on_sidebarItemSelect'
    controllers: 
      'ad-list-controller': 'AdListCtr'
      
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
      _.each @controllers, (klass, id) =>
        new ctr[klass](cid: id)
      
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
      @trigger('views-loaded')
      
    on_toolbarItemSelect: (item) ->
      @toolbar.switch(item.cid)
      
    on_sidebarItemSelect: (item) ->
      @sidebar.switch(item.cid)
      @content.switch(item.contentBlock)
      
  exports.App = App

new sm.App
Backbone.history.start(pushState: yes);