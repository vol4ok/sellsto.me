# Definitions #
AD_CREATE_L = 'ad:create.local'
AD_UPDATE_L = 'ad:update.local'
AD_DELETE_L = 'ad:delete.local'
AD_CREATE_R = 'ad:create.remote'
AD_UPDATE_R = 'ad:update.remote'
AD_DELETE_R = 'ad:delete.remote'
AD_API_URL = 'http://localhost:4000/ads'
BAYEUX_URL = 'http://localhost:4000/bayeux'

# helpers #
window.relative_time = (date, date0 = new Date()) ->
	date = new Date(date)
	date1 = new Date(date0)
	date1.setHours(0)
	date1.setMinutes(0)
	date1.setSeconds(0)
	date1.setMilliseconds(0)
	ds = parseInt((date0.getTime() - date.getTime()) / 1000)
	ps = ds - parseInt((date0.getTime() - date1.getTime()) / 1000)
	if ds < 60
		return 'меньше минуты назад'
	else if ds < 120
		return 'около минуты назад'
	else if ds < (60*60)
		m = parseInt(ds/60)
		return m + if m < 5 then ' минуты назад' else ' минут назад'
	else if ds < (120*60)
		return 'около часа назад';
	else if ds < (24*60*60)
		return "около #{parseInt(ds/3600)} часов назад"
	else if ps < (24*60*60)
		return 'вчера'
	else if ps < (48*60*60)
		return 'позавчера'
	else
		d = parseInt(ps/86400)+1
		return d + if d < 5 then ' дня назад' else ' дней назад'

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
			console.log "trigger: #{message.class}:#{message.action}.remote", message
			@trigger("#{message.class}:#{message.action}.remote", message.data)

	# Ad Class #
	Ad = Backbone.Model.extend
		idAttribute: '_id'
		sync: (method, model, options) ->
			data =
				class: 'ad'
				method: method
				clientId: $ee.clientId
			if method is 'create' or method is 'update'
				data.data = model.toJSON()
			options.contentType = 'application/json'
			options.data = JSON.stringify(data)
			return Backbone.sync(method, model, options)

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
			@isEditing = false
			@model.bind('change', @render, @)
			@model.bind('destroy', @remove, @)
		render: () ->
			console.log 'AdView::render', @model
			$(@el).html(@template(@model.toJSON()))
			@text  = @$('.show p')
			@input = @$('.edit-input')
			return @
		remove: () ->
			el = $(@el)
			el.slideUp ->	el.remove()
			return @
		edit: () ->
			return if @isEditing
			@isEditing = true
			@input.css(width: @text.width())
			@input.css(height: @text.height())
			$(@el).addClass("editing")
			@input.focus()
			return false
		update: () ->
			return unless @isEditing
			@isEditing = false
			$ee.trigger(AD_UPDATE_L, @model, body: @input.val())
			$(@el).removeClass("editing")
		delete: () ->
			$ee.trigger(AD_DELETE_L, @model)
			return false
		onKeyPress: (e) -> if e.which is 13 then @update(); false else true

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
			@body    = @$('.body')
			@list    = @$('.list')
			@submit  = @$('.submit')
			@counter = @$('.counter')
		render: (ads) ->
			console.log 'AdListView::render'
			ads.each (ad) =>
				view = new AdView(model: ad);
				@list.prepend(view.render().el)
			return @
		renderAd: (ad) ->
			console.log 'AdListView::renderAd'
			view = new AdView(model: ad);
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
		reset: ->
			@body.val('')
			@renderCounter()
		create: ->
			val = @body.val()
			return if val.length is 0
			$ee.trigger(AD_CREATE_L, body: val)
			return false
		onSubmit: () -> @create(); false
		onKeyPress: (e) -> if e.which is 13 then @create(); false else true
		onKeyUp: (e) -> @renderCounter(); true

	# AdListRouter class #
	AdListRouter = Backbone.Router.extend
		initialize: () ->
			@adList = new AdList()
			@adListView = new AdListView(el: $("#ad-list-view"))
			@adList.bind('reset', @adListView.render, @adListView)
			@adList.bind('add', @adListView.renderAd, @adListView)
			@adList.fetch()
			# register events
			$ee.bind(AD_CREATE_L, @createLocal, @)
			$ee.bind(AD_UPDATE_L, @updateLocal, @)
			$ee.bind(AD_DELETE_L, @deleteLocal, @)
			$ee.bind(AD_CREATE_R, @createRemote, @)
			$ee.bind(AD_UPDATE_R, @updateRemote, @)
			$ee.bind(AD_DELETE_R, @deleteRemote, @)
		createLocal: (data) ->
			console.log 'createLocal', data
			@adList.create(data)
			@adListView.reset()
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
	