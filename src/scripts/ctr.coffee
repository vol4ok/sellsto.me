#require mvc

namespace "sm.ctr", (exports) ->
  
  {Controller, View, Model, Collection, Router} = sm.mvc
  
  class AdModel extends Model
  
  class AdListCollection extends Collection
    model: AdModel
    url: expandApiURL('/ads')
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
      @block.bind('show', @on_blockShowFirst, this)
    on_blockShowFirst: (block) ->
      @ads = new AdListCollection
      @list.showSpinner()
      @ads.fetch success: =>
        @list.hideSpinner() #setTimeout (=> ), 1200
        @list.render(@ads)
        @block.unbind('show', @on_blockShowFirst, this)
        @block.bind('show', @on_blockShow, this)
      , error: => 
        alert('Featch failed!')
      , dataType: 'jsonp'
    on_blockShow: (block) ->
      @map.refrash()
      
      
  class SearchCtr extends Controller
    initialize: (options) ->
      super(options)
      $app.bind('views-loaded', @on_viewsLoaded, this)
      @state = 0
    on_viewsLoaded: ->
      @block   = $$('search-block')
      @sidebar = $$('sidebar')
      @seatchItem = $$('search')
      @content = $$('content-view')
      @map = $$('search-list-map')
      @block.bind('show', @on_blockShow, this)
      @seatchItem.bind('click', @on_itemClick, this)
    on_itemClick: ->
      @content.switch('search-block')
    on_blockShow: (block) ->
      @seatchItem.select()
      @map.refrash()
      
          
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