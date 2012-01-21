#require mvc
#require helpers

namespace "sm.ctr", (exports) ->
  
  {Controller, View, Model, Collection, Router} = sm.mvc
  {UrlBuilder}                                  = sm.helpers
  {SEARCH_DOMAIN}                               = sm.cfg
  
  class AdModel extends Model
  
  class AdListCollection extends Collection
    model: AdModel
    url: -> $app.expandApiURL('/ads')
    parse: (res) -> 
      return if _.isString(res) then JSON.parse(res) else res
      
  class SearchListCollection extends Collection
    initialize: (options) ->
      super(options)
      @query  = options.query
      @bounds = options.bounds
    model: AdModel
    url: ->
      new UrlBuilder(domain: SEARCH_DOMAIN, path: "/ad/select")
      .on("q", @query)
      .on("location.bottom", @bounds.getSouthWest().lat())
      .on("location.top",    @bounds.getNorthEast().lat())
      .on("location.left",   @bounds.getSouthWest().lng())
      .on("location.right",  @bounds.getNorthEast().lng()).url()
    parse: (res) ->
      return if _.isString(res) then JSON.parse(res) else res
      
  class AdListCtr extends Controller
    initialize: (options) ->
      super(options)
      $app.bind('views-loaded', @on_viewsLoaded, this)
      @state = 0
    on_viewsLoaded: ->
      @block = $$('list-block')
      @list = $$('ad-list')
      @map = $$('ad-list-map')
      @list_block = $$('list-block')
      @block.bind('show', @on_blockShowFirst, this)
      @list_block.bind('show', @on_blockShow, this)
    on_blockShowFirst: (block) ->
      @ads = new AdListCollection
      @list.showSpinner()
      @ads.fetch success: =>
        @list.hideSpinner()
        @list.render(@ads)
        @block.unbind('show', @on_blockShowFirst, this)
      , error: => 
        console.error('Featch failed!')
      , dataType: 'json'
    on_blockShow: (block) ->
      @map.refresh()
      
      
  class SearchCtr extends Controller
    initialize: (options) ->
      super(options)
      $app.bind('views-loaded', @on_viewsLoaded, this)
      @state = 0
    on_viewsLoaded: ->
      @block   = $$('search-block')
      @sidebar = $$('sidebar')
      @searchItem = $$('search')
      @content = $$('content-view')
      @map = $$('search-list-map')
      @list = $$('search-list')
      @block.bind('show', @on_blockShow, this)
      @searchItem.bind('click', @on_itemClick, this)
      @searchItem.bind('search', @on_search, this)
    on_itemClick: ->
      @content.switch('search-block')
    on_search: (query) ->
      console.log 'on_search', query
      @ads = new SearchListCollection(query: query, bounds: @map.getBounds())
      @list.showSpinner()      
      @ads.fetch success: =>
        @list.hideSpinner()
        @list.render(@ads)
        @map.renderMarkers(@ads)
    on_blockShow: (block) ->
      @searchItem.select()
      @map.refresh()
          
  class ModalCtr extends Controller
    initialize: (options) ->
      super(options)
      @buttonCid = options.button
      @modalCid  = options.modal
      $app.bind('views-loaded', @on_viewsLoaded, this)
    on_viewsLoaded: ->
      @toolbar = $$('toolbar')
      @underlay = $$('modal-underlay')
      @button = $$(@buttonCid)
      @modal  = $$(@modalCid)
      @button.bind('click', @on_click, this)
      @button.bind('select', @on_select, this)
      @button.bind('deselect', @on_deselect, this)
      @modal.bind('close', @on_modal_close, this)
      @underlay.bind('click', @on_modal_close, this)
    on_click: (item) ->
      item.select()
    on_select: (item) ->
      @underlay.show()
      @modal.show()        
    on_deselect: (item) ->
      @underlay.hide()
      @modal.hide()
    on_modal_close: ->
      @underlay.hide()
      @modal.hide()
      @button.deselect()
      
    
  exports extends {AdListCtr, SearchCtr, ModalCtr}