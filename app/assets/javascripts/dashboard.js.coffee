# Definitions #
AD_CREATE_L = 'ad:create.local'
AD_UPDATE_L = 'ad:update.local'
AD_DELETE_L = 'ad:delete.local'
AD_CREATE_R = 'ad:create.remote'
AD_UPDATE_R = 'ad:update.remote'
AD_DELETE_R = 'ad:delete.remote'
AD_API_URL = 'http://localhost:4000/ads'
BAYEUX_URL = 'http://localhost:4000/bayeux'

$ () ->
	_.templateSettings = interpolate: /\{\{(.+?)\}\}/g
	
	# EventHab Class #
	EventsHub = (options) ->
		@initialize.apply(@, arguments)
		return
	_.extend EventsHub.prototype, Backbone.Events,
		initialize: (bayeuxUrl) ->
			@bayeux = new Faye.Client(bayeuxUrl) if bayeuxUrl
		subscribe: (channels) ->
			return false unless @bayeux
			if _.isArray(channels)
				for channel in channels
					@bayeux.subscribe(channel, @_listen)
			else
				@bayeux.subscribe(channels, @_listen)
			return true
		_isValid: (message) ->
			return true
		_listen: (message) ->
			return unless @_isValid(message)
			@trigger("#{msg.class}:#{msg.action}.remote")

	# Ad Class #
	Ad = Backbone.Model.extend()

	# AdView Class #
	AdView = Backbone.View.extend
		tagName: 'li'
		template: _.template($('#ad-view').html())
		events:
			"click .delete-link"  : "delete"
			"click .edit-link"    : "edit"
			"dblclick .show"      : "edit"
			"focusout .edit-input": "update"
			"keypress .edit-input": "onKeyPress"
		initialize: () ->
			_.bindAll(@, 'render')
			@isEditing = false
		render: () ->
			$(@el).html(@template(this.model.toJSON()))
			@disp  = @$('.show p')
			@input = @$('.edit-input')
		edit: () ->
			return if @isEditing
			@input.css(width: @text.width())
			@input.css(height: @text.height())
			$(@el).addClass("editing")
			@input.focus()
			@isEditing = true
		update: () ->
			return unless @isEditing
			@isEditing = false
			ad = {}
			$eh.trigger(AD_UPDATE_L, ad)
		delete: () ->
			ad = {}
			$eh.trigger(AD_DELETE_L, ad)
		onKeyPress: (e) -> @update() if e.which is 13; false

	# AdList class #
	AdList = Backbone.Collection.extend
		model: Ad
		url: AD_API_URL

	# AdListView class #
	AdListView = Backbone.View.extend
		events: 
			"click .submit" : "onSubmit"
			"keyup .body"   : "renderCounter"
			"keypress .body": "onKeyPress"
		initialize: () ->
			_.bindAll(@, 'render', 'renderAd')
			@body    = @$('.body')
			@list    = @$('.list')
			@submit  = @$('.submit')
			@counter = @$('.counter')
		render: (ads) ->
			ads.each (ad) =>
			view = new AdView(model: ad);
			@list.prepend(view.render().el)
			return @
		renderAd: (ad) ->
			view = new AdView(model: ad);
			# insert with slide-down effect
			li = $(view.render().el).hide()
			@list.prepend(li)
			li.slideDown()
			return @
		renderCounter: () ->
			len = @body.val().length
			@counter.text(len)
			if len is 0
				@submit.attr(disabled: true)
			else
				@submit.removeAttr('disabled')
			return @
		create: ->
			val = @body.val()
			return if val.length is 0
			$eh.trigger(AD_CREATE_L, body: val)
		onSubmit: () -> @create(); false
		onKeyPress: (e) -> @create() if e.which is 13; true
		onKeyUp: (e) -> @renderCounter(); true

	# AdListRouter class #
	AdListRouter = Backbone.Router.extend
		initialize: () ->
			@adList = new AdList()
			@adListView = new AdListView(el: $("#ad-list-view"))
			@adList.fetch()
			# register events
			$eh.bind(AD_CREATE_L, @createLocal)
			$eh.bind(AD_UPDATE_L, @updateLocal)
			$eh.bind(AD_DELETE_L, @deleteLocal)
			$eh.bind(AD_CREATE_R, @createRemote)
			$eh.bind(AD_UPDATE_R, @updateRemote)
			$eh.bind(AD_DELETE_R, @deleteRemote)
		createLocal: (ad) ->
			console.log 'createLocal', ad
			#@adListView.renderAd(ad)
		updateLocal: (ad) ->
			console.log 'updateLocal', ad
		deleteLocal: (ad) ->
			console.log 'deleteLocal', ad
		createRemote: (ad) ->
			console.log 'createRemote', ad
		updateRemote: (ad) ->
			console.log 'updateRemote', ad
		deleteRemote: (ad) ->
			console.log 'deleteRemote', ad

	AppController = Backbone.Router.extend
		initialize: ->
			@adListRouter = new AdListRouter()
	
	window.$eh = new EventsHub(BAYEUX_URL)
	$eh.subscribe('/foo')
	window.$app = new AppController()
	