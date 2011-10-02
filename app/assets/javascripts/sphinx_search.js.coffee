#= require lang
#= require jquery
#= require underscore
#= require backbone
#= require backbone_ext
#= require config
#= require module/sellstome


namespace "sellstome.sphinx", (exports) ->
	#import section
	$ = jQuery
	{expandApiURL} = sellstome.common

	#module constants
	SEARCH_URL = expandApiURL('/searchBlog')

	#todo zhugrov a - does it should be refactored to common logic?
	_.templateSettings = interpolate: /\{\{(.+?)\}\}/g
	# note: zhugrov a - yes this is not right
	exports.BlogViewTemplate = null

	### contains init logic on dom page ready ###
	initialize = ->
		new PageController()
		exports.BlogViewTemplate = _.template($('#search-result-template').html())
		return

	exports.initialize = initialize

	### Handles a global page operations ###
	class PageController extends Backbone.Controller
		### @type {sellstome.sphinx.SearchResultList} ###
		seachResults: null
		### @type {sellstome.sphinx.BlogView} ###
		blogView: null
		### @type {sellstome.sphinx.SearchView} ###
		searchView: null

		initialize: ->
			@searchView = new SearchView({el: $('#searchQuery').get(0)})
			@searchView.bind( SEARCH_SEARCH_L, @_search, this )
			@blogView = new BlogView({el: $('#searchResultsPlaceholder').get(0)})
			@searchResults = new SearchResultList()
			@searchResults.bind( 'add'   , @blogView.render , @blogView )
			@searchResults.bind( 'reset' , @blogView.render , @blogView )
			return

		### Fetch the search results that match given term ###
		_search: ( query ) ->
			@searchResults.fetch({ data: { query: query } })
			return this

	class SearchResult extends Backbone.Model
		idAttribute: "id"

	### List of the search results ###
	class SearchResultList extends Backbone.Collection
		### @type {sellstome.sphinx.SearchResult} ###
		model: SearchResult
		### @type {string} ###
		url: SEARCH_URL

	### Responsible for the search input block ###
	class SearchView extends Backbone.View
		events:
			"keypress #query" :   "_search"
			"click    #search":   "_search"

		initialize: ->
			#do nothing for now
			return

		_search: (event) ->
			if event.which is 13 or event.type is 'click'
				@trigger( SEARCH_SEARCH_L , $(@el).find('#query').val() )
				return false
			else
				true
			return

	### Renders a set of the search results ###
	class BlogView extends Backbone.View

		intitialize: ->
			return

		### renders the list of search results ###
		### @type {sellstome.sphinx.SearchResultList} ###
		render: (searchResults) ->
			$(@el).empty()
			searchResults.each ( searchItem ) =>
				view = new BlogSearchResultView({ model: searchItem, template: exports.BlogViewTemplate })
				$(@el).prepend(view.render().el)
			return this

	class BlogSearchResultView extends Backbone.View
		###@type {string}###
		tagName: 'div'

		### @type(function(data: sellstome.sphinx.)) template used for generating view html###
		template: null

		### class that would be applied to the container element ###
		className: 'ad'

		### initialize the search result view ###
		initialize: (options) ->
			@template = options.template
			return

		render: ->
			data = @model.toJSON()
			$(@el).html(@template(data))
			return this

		### removes elements from dom tree ###
		remove: ->
			$(@el).remove()
			return this

jQuery(document).ready( sellstome.sphinx.initialize )


