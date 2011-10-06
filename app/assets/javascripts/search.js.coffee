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
	
	{expandApiURL} = sellstome.common
	{relative_time} = sellstome.helpers
	
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
	

	###----[ DETAIL ]----###	
	
	class DetailPaneController extends Backbone.Controller
			
	###----[ PAGE ]----###
	
	class AsideItemView extends Backbone.View
		initialize: (options) ->
			@template = options.template
		render: ->
			$(@el).html(@template(@model.toJSON()))
			console.log @el
			return @el
			
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
		el: '#page'
		initialize: (options) ->
			@template = options.template
		render: (list) ->
			$(@el).html(@template())
			@aside = @$('#aside')
			@map = @$('map')
			@$('.resizer').resizer(target: @aside)
			console.log 'i\'m here!', list
			list.forEach (model) =>
				console.log 'view = new AsideItemView'
				view = new AsideItemView
					model: model
					template: _.template($('#aside-item').html())
				@aside.append(view.render())
			return @el
		
	class PageController extends Backbone.Controller
		initialize: (options) ->
		show: ->
		hide: ->
			
	class ProfilePageController extends PageController
		initialize: ->
			
	class SearchPageController extends PageController
		initialize: (options) ->
		search: (query) -> alert(query)
		
	class ListPageController extends PageController
		initialize: (options) ->
			super(options)
			@_adList = new AdList()
			@_aside = new PageView(template: _.template($('#search-page').html()))
			@_adList.fetch
				success: => @_initializeCompletion(0)
				error: => @_initializeCompletion(1)
			
		_initializeCompletion: (err) ->
			@_aside.render(@_adList)
		
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
				list: new ListPageController()
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
	_.templateSettings = interpolate: /\{\{(.+?)\}\}/g
	$app = new sellstome.search.SellsApp()