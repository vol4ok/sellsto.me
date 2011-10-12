#= require lang
#= require jquery
#= require iscroll
#= require backbone
#= require backbone_ext
#= require module/resizer
#= require module/sellstome
#= require module/generators
#= require module/map/overlays
#= require module/map/geolocation
#= require module/map/controls

namespace "sellstome.search", (exports) ->
  
  {LatLng, Marker, MapTypeId, Map, ControlPosition, OverlayView} = google.maps
  GoogleEventHub = google.maps.event
  {GeolocationRequest} = sellstome.geolocation
  {generateCircle, generateRect, generatePriceBubble} = sellstome.generators
  {rand} = sellstome.helpers
  
  {expandApiURL} = sellstome.common
  {relative_time} = sellstome.helpers
  

  ###----[ DETAIL ]----###  
  
  class DetailPaneController extends Backbone.Controller
      
  ###----[ PAGE ]----###
  
  class AsideItemView extends Backbone.View
    className: 'ad-item'
    tagName: 'div'
    events:
      'click': 'on_click'
    initialize: (options) ->
      @template = options.template
    render: ->
      $(@el).html(@template(@model.toJSON()))
      return @el
    on_click: (e) -> @trigger('select', this)
      
  class AdModel extends Backbone.Model
    card: ->
    like: ->
    reply: ->
    tweet: ->
    facebook: ->
      
  class AdList extends Backbone.Collection
    model: AdModel
    url: expandApiURL('/ads')
    
  class PageView extends Backbone.View
    SEPARATOR_SIZE: 5
    ASIDE_MINSIZE: 400
    MAP_MINSIZE: 250
    events:
      'resizer-resize .resizer': 'on_resize'
    #el: '#page'
    tagName: 'div'
    initialize: (options) ->
      @template = options.template
      @_isTabActive = no
      @_isTabRendered = no
      
    renderMap: ->
      request = new GeolocationRequest()
      
      positionMap = (position) =>
        mapCenterPosition = new LatLng(position.coords.latitude, position.coords.longitude)
        options =
          zoom: 12
          center: mapCenterPosition
          mapTypeId: MapTypeId.ROADMAP
          disableDefaultUI: true
        @gmap = new Map($('#map').get(0), options)
      errorCallback = (error) =>
        alert('error')
        
      request.getCurrentPosition(positionMap, errorCallback)
    
    setList: (@list) ->
      
    render: (list) ->
      $(window).resize _.bind(@on_resizeWindow,this)
      $(@el).html(@template())
      $('#pages').append(@el)
      @aside = @$('#aside')
      @aside
        .css('min-width': @ASIDE_MINSIZE)
        .width(Math.round($(@el).width()*0.45))
      @itemList = @$('.item-list')
      @map = @$('#map')
        .css('min-width': @MAP_MINSIZE)
        .width($(@el).width() - @aside.width()-1)
      @_resizer = @$('.resizer')
      @_resizer.resizer
        width: @SEPARATOR_SIZE
        offset: @aside.width()
        validate: _.bind(@_validateSize, this)
      @list.forEach (model) =>
        view = new AsideItemView
          model: model
          template: _.template($('#aside-item').html())
        @itemList.append(view.render())
      @renderMap()
      @_isTabRendered = yes
      # @scroll = new iScroll 'aside', 
      #   hScroll: false
      #   hScrollbar: false
      #   fadeScrollbar: true
      #$('#aside').lionbars('dark',false,true,true) 
      return @el
      
    show: ->
      unless @_isTabRendered
        $(@el).css(opacity: 0)
        @render() 
        $(@el).animate("opacity": 1)
      else
        #$(@el).show()
        $(@el).fadeIn 200, =>
          GoogleEventHub.trigger(@gmap, 'resize')
      @_isTabActive = yes
    hide: ->
      #$(@el).hide()
      $(@el).fadeOut(200)
      @_isTabActive = no
      
    _validateSize: (offset) ->
      unless @_asideMinSize?
        @_asideMinSize = @ASIDE_MINSIZE
        console.log 'min', @_asideMinSize
      unless @_asideMaxSize?
        @_asideMaxSize = $(window).width() - (@SEPARATOR_SIZE >> 1) - @MAP_MINSIZE
        console.log 'max', @_asideMaxSize
      if offset < @_asideMinSize
        return @_asideMinSize
      if offset > @_asideMaxSize
        return @_asideMaxSize
      return offset
      
    _resizeWindowComplete: ->
      @_inc--
      if @_inc is 0
        ww = $(@el).width()
        aw = @aside.width()
        @_asideMaxSize = ww - (@SEPARATOR_SIZE >> 1) - @MAP_MINSIZE if @_asideMaxSize?
        if ww >= aw + @MAP_MINSIZE
          @map.css(width: ww - aw - 1)
        else if ww >= @ASIDE_MINSIZE + @MAP_MINSIZE
          @aside.css(width: ww - @MAP_MINSIZE - 1)
          @_resizer.resizer('option', 'offset', ww - @MAP_MINSIZE)
        #@map.css(opacity: 1)
        @map.stop().animate({ "opacity": 1 })
        
    on_select: (view) -> @trigger('select', view)
    on_resizeWindow: (e) ->
      return unless @_isTabActive
      # make this div transparent, 
      # in order to map aren't twitching when it appear after resize ###
      @map.css(opacity: 0)
      @_inc = 0 unless @inc?
      @_inc++
      setTimeout (=> @_resizeWindowComplete()), 300
    on_resize: (event,offset) ->
      @aside.css(width: offset)
      @map.css(width: $(@el).width() - offset-1)
      
  class FishPage extends Backbone.View
    tagName: 'div'
    initialize: (options) ->
      @template = options.template
      @_isTabActive = no
      @_isTabRendered = no
    render: ->
      $(@el).html(@template())
      $('#pages').append(@el)
      @_isTabRendered = yes
    show: ->
      unless @_isTabRendered
        $(@el).css(opacity: 0)
        @render() 
        $(@el).animate("opacity": 1)
      else
        #$(@el).show()
        $(@el).fadeIn(200)
    hide: ->
      #$(@el).hide()
      $(@el).fadeOut(200)
      
  class PageController extends Backbone.Controller
    initialize: (options) ->
      @_page = null
    show: -> @_page.show()
    hide: -> @_page.hide()
      
  class ProfilePageController extends PageController
    initialize: (options) ->
      super(options)
      @_page = new FishPage(template: _.template($('#profile-page').html()))
    
  class FolowersAdsPageController extends PageController
    initialize: (options) ->
      super(options)
      @_adList = new AdList()
      @_page = new PageView(template: _.template($('#folowers-ads-page').html()))
      @_page.bind('select', @on_select, this)
      @_adList.fetch
        success: => @_initializeCompletion(0)
        error: => @_initializeCompletion(1)
      
    _initializeCompletion: (err) ->
      @_page.setList(@_adList)
    on_select: (view) ->
      
  class MessagesPageController extends PageController
    initialize: (options) ->
      super(options)
      @_page = new FishPage(template: _.template($('#messages-page').html()))
        
  class PreferencesPageController extends PageController
    initialize: (options) ->
      super(options)
      @_page = new FishPage(template: _.template($('#preferences-page').html()))
        
  class SearchPageController extends PageController
    initialize: (options) ->
      super(options)
      @_page = new FishPage(template: _.template($('#search-page').html()))
    search: (query) -> alert(query)
      
  
  ###----[ TOOLBAR ]----###
  
  class ToolbarItemView extends Backbone.View
    tagName: 'li'
    className: 'menu-ico'
    events:
      'click': 'on_click'
    initialize: (options) ->
      @title = options.title if options?
      @_rendered = no
    render: ->
      unless @_rendered
        $(@el).text(@title) 
        @_rendered = yes
      return @el
    select: -> $(@el).addClass('selected')
    deselect: -> $(@el).removeClass('selected')
    on_click: -> @trigger('select', this)
  
  class ToolbarView extends Backbone.View
    el: '#toolbar'
    events:
      'keypress .search-input': 'on_keyPress'
    initialize: ->
      @_menu = @$('.menu')
    renderItem: (view) ->
      @_menu.append(view.render())
    on_keyPress: (e) ->
      return true unless e.which is 13
      @trigger('search', $(e.currentTarget).val()) 
      return false
      
  
  class ToolbarController extends Backbone.Controller
    initialize: ->
      @_view = new ToolbarView()
      @_items = []
      @_cidToIndex = {}
      @_view.bind('search', @on_search, this)
    addItem: (item) ->
      @_cidToIndex[item.cid] = @_items.length
      @_items.push(item)
      item.bind('select', @on_itemSelect, this)
      @_view.renderItem(item)
    selectItem: (index) ->
      @_items[@_index].deselect() if @_index? and @_index != index
      if index? and 0 <= index < @_items.length
        @_index = index
        @_items[index].select()
      else
        @_index = null
    on_search: (query) -> @trigger('search', query)
    on_itemSelect: (item) -> 
      @trigger('item-select', @_cidToIndex[item.cid])
  
  
  ###----[ APP ]----###
    
  class SellsApp extends Backbone.Router
    initialize: ->
      @_toolbar = new ToolbarController()
      @_pages = 
        0: new ProfilePageController()
        1: new MessagesPageController()
        2: new FolowersAdsPageController()
        3: new PreferencesPageController
        4: new SearchPageController()
      menuItem = new ToolbarItemView(title: 'H')
      @_toolbar.addItem(menuItem)
      menuItem = new ToolbarItemView(title: 'M')
      @_toolbar.addItem(menuItem)
      menuItem = new ToolbarItemView(title: 'l')
      @_toolbar.addItem(menuItem)
      menuItem = new ToolbarItemView(title: 'y')
      @_toolbar.addItem(menuItem)
      
      @_index = 0
      @_pages[@_index].show()
      
      @_toolbar.selectItem(0)
      @_toolbar.bind('item-select', @_toolbar.selectItem, @_toolbar)
      @_toolbar.bind('item-select', @on_changePage, this)
      @_toolbar.bind('search', @on_search, this)
    on_search: (query) ->
      @_pages.search.search(query)
      @_pages.search.show()
    on_changePage: (page) ->
      console.log 'on_changePage', page, @_pages[@_index]
      @_pages[@_index].hide()
      @_index = page
      @_pages[@_index].show()
        
  exports.SellsApp = SellsApp
      
$ () ->
  _.templateSettings = interpolate: /\{\{(.+?)\}\}/g
  $app = new sellstome.search.SellsApp()