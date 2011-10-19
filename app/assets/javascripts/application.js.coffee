#= require lang
#= require jquery
#= require backbone
#= require backbone_ext
#= require module/ui
#= require module/resizer
#= require module/sellstome

namespace "sellstome", (exports) ->
  
  {ui} = sellstome
  
  root.$ctrs = {}
  root.$views = {}
  root.$NS =
    '#': $views
    '$': $ctrs
  
  class CTRBase extends Backbone.Controller
    initialize: (options) ->
      @cid = options.id if options? and options.id?
      $ctrs[@cid] = this
  
  class SellsApp extends Backbone.Router
    routes:
      '*path': 'routeTo'
    bindings:
      '#toolbar:select': '#toolbar:switch'
      '#tabpane:select': '#tabpane:switch'
      '#list-tab-button:select': '$app:on_tabSwitch'
      '#mine-tab-button:select': '$app:on_tabSwitch'
      '#messages-tab-button:select': '$app:on_tabSwitch'
      '#card-tab-button:select': '$app:on_tabSwitch'
      '#like-tab-button:select': '$app:on_tabSwitch'
      '#search-tab-button:select': '$app:on_tabSwitch'
    initialize: ->
      @cid = 'app'
      $ctrs[@cid] = this
      new CTRBase
      
      $(document).ready(_.bind(@on_domLoaded, this))
      
    routeTo: (path) ->
      console.log 'routeTo:', path
    _initAutoloadClasses: ->
      $('.autoload').each (i, _el) =>
        el = $(_el)
        el.removeClass('autoload')
        #console.log _el.tagName, _el.type, el.data()
        if _el.tagName == 'SCRIPT' and _el.type == 'html/template'
          view = new ui[el.data('class')](template: _.template($(el).html()))
        else
          view = new ui[el.data('class')](el: _el)
    makeBindings: (trgStr,srcStr) ->
      [srcCid, event]  = srcStr.split(':')
      [trgCid, method] = trgStr.split(':')
      srcNs = $NS[srcCid[0]]
      trgNs = $NS[trgCid[0]]
      srcCid = srcCid.slice(1)
      trgCid = trgCid.slice(1)
      #console.log srcNs,srcCid,event,' -> ', trgNs,trgCid,method
      srcNs[srcCid].bind(event, trgNs[trgCid][method], trgNs[trgCid])  
    _initBindings: ->
      _.each(@bindings, @makeBindings)
    on_domLoaded: ->
      console.log '!on_domLoaded'
      @_initAutoloadClasses()
      @_initBindings()
    on_tabSwitch: (view) ->
      console.log 'on_tabSwitch', view.blockCid
      # contentView = $views['content-view']
      # unless contentView.blocks[view.blockCid]?
      #   contentView.addBlock($views[view.blockCid])
      # contentView.switch(view.blockCid)
      
  
  exports.App = SellsApp
  
$app = new sellstome.App
Backbone.history.start(pushState: yes);