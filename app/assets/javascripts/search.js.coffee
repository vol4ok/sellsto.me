#= require lang
#= require jquery
#= require backbone
#= require backbone_ext
#= require module/resizer
#= require module/sellstome
#= require module/generators
#= require module/map/overlays
#= require module/map/geolocation
#= require module/map/controls

namespace "sellstome.search", (exports) ->
	
	# class AdModel
	# 	default:
	# 		id
	# 		author
	# 		avator
	# 		photo
	# 		date
	# 		location
	# 		price
	# 		count
	# 		message
			
	
	###----[ MAP ]----###
	
	class MapController extends Backbone.Controller
	

	###----[ DETAIL ]----###	
	
	class DetailPaneController extends Backbone.Controller
	
		
	###----[ ASIDE ]----###
	
	class AsideView extends Backbone.View
		initialize: (options) ->
			@template = options.template
		
	class AsideController extends Backbone.Controller
		class AsideItemView extends Backbone.Controller
		class AsideItemController extends Backbone.Controller
			card: ->
			like: ->
			reply: ->
			tweet: ->
			facebook: ->
		initialize: ->
			@detailPaneContreoller = new DetailPaneController
			
	###----[ CONTENT ]----###
		
	class AdListCollection extends Backbone.Collection
		
	class PageController extends Backbone.Controller
		initialize: ->
		show: ->
		hide: ->
			
			
	class ProfilePageController extends PageController
		initialize: ->
			@_aside = new AsideView
			
	class SearchPageController extends PageController
		initialize: ->
		search: (query) -> alert(query)
		
		
	###----[ TOOLBAR ]----###
	
	class ToolbarItemView extends Backbone.View
		tagName: 'li'
		className: 'menu-ico'
		events:
			'click': 'on-click'
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
		'on-click': -> @trigger('select', this)
	
	class ToolbarView extends Backbone.View
		el: '#toolbar'
		events:
			'keypress .search-input': 'on-key-press'
		initialize: ->
			@_menu = @$('.menu')
		renderItem: (view) ->
			@_menu.append(view.render())
		'on-key-press': (e) ->
			return true unless e.which is 13
			@trigger('search', $(e.currentTarget).val()) 
			return false
			
	
	class ToolbarController extends Backbone.Controller
		initialize: ->
			@_view = new ToolbarView()
			@_items = []
			@_cidToIndex = {}
			@_view.bind('search', @['on-search'], this)
		addItem: (item) ->
			@_cidToIndex[item.cid] = @_items.length
			@_items.push(item)
			item.bind('select', @['on-item-select'], this)
			@_view.renderItem(item)
		selectItem: (index) ->
			@_items[@_index].deselect() if @_index? and @_index != index
			if index? and 0 <= index < @_items.length
				@_index = index
				@_items[index].select()
			else
				@_index = null
		'on-search': (query) -> @trigger('search', query)
		'on-item-select': (item) -> 
			@trigger('item-select', @_cidToIndex[item.cid])
	
	
	###----[ APP ]----###
		
	class SellsApp extends Backbone.Router
		initialize: ->
			@_toolbar = new ToolbarController()
			@_pages = 
				search: new SearchPageController()
				progile: new ProfilePageController()

			menuItem = new ToolbarItemView(title: 'H')
			@_toolbar.addItem(menuItem)
			menuItem = new ToolbarItemView(title: 'M')
			@_toolbar.addItem(menuItem)
			menuItem = new ToolbarItemView(title: 'l')
			@_toolbar.addItem(menuItem)
			menuItem = new ToolbarItemView(title: 'y')
			@_toolbar.addItem(menuItem)
			
			@_toolbar.selectItem(0)
			@_toolbar.bind('item-select', @_toolbar.selectItem, @_toolbar)
			@_toolbar.bind('search', @['on-search'], this)
		'on-search': (query) ->
			@_pages.search.search(query)
			@_pages.search.show()
		'on-change-page': (page) ->
				
	exports.SellsApp = SellsApp
			
$ () ->
	$app = new sellstome.search.SellsApp()