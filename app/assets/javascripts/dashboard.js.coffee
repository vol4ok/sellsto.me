#= require config
#= require common
#= require uploader
#= require ad
#= require helpers

$ () ->
	_.templateSettings = interpolate: /\{\{(.+?)\}\}/g
		
	# EventEmitter Class #
	EventEmitter = (options) ->
		@initialize.apply(@, arguments)
		return
	_.extend EventEmitter.prototype, Backbone.Events,
		initialize: (bayeuxUrl) ->
			@clientId = Math.round(Math.random()*10000)
			@bayeux = new Faye.Client(bayeuxUrl) if bayeuxUrl
		subscribe: (channels) ->
			return false unless @bayeux
			if _.isArray(channels)
				for channel in channels
					@bayeux.subscribe(channel, @_listen, @)
			else
				@bayeux.subscribe(channels, @_listen, @)
			return true
		_isValid: (message) ->
			if message.clientId and parseInt(message.clientId) is @clientId
				console.warn 'filter message', message
				return false
			return true
		_listen: (message) ->
			return unless @_isValid(message)
			console.log "trigger: #{message.class}:#{message.action}.remote",
				 message
			@trigger("#{message.class}:#{message.action}.remote", message.data)		

	# AdListRouter class #
	class AdListRouter extends Backbone.Router
		
		{AdList, AdListView, AdBuilderView} = sellstome.ad
		
		initialize: () ->
			@adList = new AdList()
			@adListView = new AdListView(el: $("#ad-list-view"))
			@adBuilderView = new AdBuilderView(el: $("#ad-builder-view"))
			@adList.bind('reset', @adListView.render, @adListView)
			@adList.bind('add', @adListView.renderOne, @adListView)
			
			@adList.fetch()
			# register events
			$ee.bind(AD_CREATE_L, @createLocal, this)
			$ee.bind(AD_UPDATE_L, @updateLocal, this)
			$ee.bind(AD_DELETE_L, @deleteLocal, this)
			$ee.bind(AD_CREATE_R, @createRemote, this)
			$ee.bind(AD_UPDATE_R, @updateRemote, this)
			$ee.bind(AD_DELETE_R, @deleteRemote, this)
			$ee.bind(AD_UPLOAD_L, @filesUpload, this)
			$ee.bind('ad:build-complete.local', @buildComplete, this)
		createLocal: ->
			console.log 'createLocal', data
			@adBuilderView.build()
		buildComplete: (data) ->
			console.log 'buildComplete', data
			@adList.create(data)
			@adBuilderView.reset()
		updateLocal: (model, data) ->
			console.log 'updateLocal', model, data
			model.save(data)
		deleteLocal: (model) ->
			console.log 'deleteLocal', model
			model.destroy()
			@adList.remove(model)
		createRemote: (data) -> 
			console.log 'createRemote', data
			@adList.add(data) unless @adList.get(data._id)
		updateRemote: (data) ->
			console.log 'updateRemote', data
			ad.set(data) if ad = @adList.get(data._id)
		deleteRemote: (id) ->
			console.log 'deleteRemote', id
			if ad = @adList.get(id)
				ad.trigger('destroy', ad, ad.collection)
				@adList.remove(ad)
			

	AppController = Backbone.Router.extend
		initialize: ->
			@adListRouter = new AdListRouter()
	
	window.$ee = new EventEmitter(BAYEUX_URL)
	$ee.subscribe(['/foo'])
	window.$app = new AppController()
	