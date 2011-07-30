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
	
	window.Ad = Backbone.Model.extend
		idAttribute: '_id'
		initialize: ->
			reltime = relative_time(@get('created_at'))
		clear: ->
			@destroy()
			@view.remove()
			
	window.AdList = Backbone.Collection.extend
		model: Ad
		url: 'http://localhost:4000/ads'
	
	window.AdView = Backbone.View.extend
		tagName: 'li'
		template: _.template($('#ad-template').html())
		events: 
			"click .destroy-link": "clear"
			"click .edit-link" : "edit"
			"dblclick .disp" : "edit"
			"keypress .edit-input": "onKeyPress"
			"blur .edit-input": "editComplete"
		initialize: ->
			_.bindAll(@, 'render')
			@model.bind('change', @render)
			@model.view = @
		render: ->
			$(@el).html(@template(this.model.toJSON()))
			@text = @$('.disp p')
			@input = @$('.edit-input')
			return @
		clear: ->
			@model.clear()
			false
		remove: ->
			$el = $(@el)
			$el.slideUp ->
				$el.remove()
		onKeyPress: (e) ->
			if e.which is 13
				@editComplete()
				return false
		edit: ->
			@input.css(width: @text.width())
			@input.css(height: @text.height())
			$(@el).addClass("editing")
			@input.focus()
		editComplete: ->
			@model.save(body: @input.val())
			$(@el).removeClass("editing")
			
	window.AppView = Backbone.View.extend
		el: $("#ads")
		events: 
			"click #submit": "newAd"
			"keyup #ad-body":  "renderCounter"
			"keypress #ad-body":  "onKeyPress"
		initialize: ->
			_.bindAll(@, 'addOne', 'addAll')
			@input = @$('#ad-body')
			@list = @$('#ad-list')
			@counter = @$('#counter')
			@submit = @$('#submit')
			ads.bind('add', @addOne)
			ads.bind('reset', @addAll)
			ads.fetch()
			@renderCounter()
		addOne: (ad) ->
			view = new AdView(model: ad);
			$li = $(view.render().el).hide()
			@list.prepend($li)
			$li.slideDown()
		addAll: ->
			ads.each (ad) =>
				view = new AdView(model: ad);
				@list.prepend(view.render().el)
		renderCounter: ->
			len = @input.val().length
			@counter.html(len)
			if len is 0
				@submit.attr(disabled: true)
			else
				@submit.removeAttr('disabled')
			return @
		newAd: ->
			val = @input.val()
			return if val.length is 0
			ad = body: val
			#ads.create(ad);
			client.publish('/foo', ad)
			@input.val('')
			@renderCounter()
			false
		onKeyPress: (e) ->
			if e.which is 13 # and e.ctrlKey is on
				@newAd()
				@input.blur()
				return false
	
	window.ads = new AdList	
	window.app = new AppView;
	window.client = new Faye.Client('http://localhost:4000/bayeux')
	sub = client.subscribe '/foo', (msg)->
		console.log(msg)
		ads.create(msg)