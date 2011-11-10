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
    
  exports extends {AdListCtr}