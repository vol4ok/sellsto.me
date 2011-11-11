#require mvc

namespace "sm.ctr", (exports) ->
  
  {Controller, View, Model, Collection, Router} = sm.mvc
  
  class AdModel extends Model
  
  class AdListCollection extends Collection
    model: AdModel
    url: expandApiURL('/ads')
  
  class AdListCtr extends Controller
    initialize: ->
      console.log 'AdListCtr'
      $app.bind('views-loaded', @on_viewsLoaded, this)
      @state = 0
    on_viewsLoaded: ->
      @block = $$('list-block')
      @list = $$('ad-list')
      @block.bind('show', @on_blockShow, this)
    on_blockShow: (block) ->
      console.log 'on_blockShow', block.cid
      @ads = new AdListCollection
      @list.showSpinner()
      @ads.fetch success: =>
        @list.hideSpinner() #setTimeout (=> ), 1200
        @list.render(@ads)
        
  class ModalController extends Controller
    initialize: (options) ->
      @buttonCid = options.button
      @modalCid  = options.modal
      $app.bind('views-loaded', @on_viewsLoaded, this)
    on_viewsLoaded: ->
      @toolbar = $$('toolbar')
      @underlay = $$('modal-underlay')
      @button = $$(@buttonCid)
      @modal  = $$(@modalCid)
      @button.bind('select', @on_select, this)
      @button.bind('deselect', @on_deselect, this)
      @modal.bind('close', @on_modal_close, this)
      @underlay.bind('click', @on_modal_close, this)
    on_select: (item) ->
      @underlay.show()
      @modal.show()        
    on_deselect: (item) ->
      @underlay.hide()
      @modal.hide()
    on_modal_close: ->
      @underlay.hide()
      @modal.hide()
      @toolbar.switch(null)
      
    
  exports extends {AdListCtr, ModalController}