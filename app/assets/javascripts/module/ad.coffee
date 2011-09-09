#= require lang
#= require jquery
#= require backbone
#= require underscore
#= require json2
#= require module/uploader

namespace 'sellstome.ad', (exports) ->
	console.log 'Uploader', Uploader
	{Upload, Uploader, UploadView} = sellstome.uploader
	
	### Ad Class ###

	class Ad extends Backbone.Model
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

	### AdView Class ###

	class AdView extends Backbone.View
	
		tagName: 'li'

		template: (data) -> 
			Object.getPrototypeOf(this).template = _.template($('#ad-view').html())
			@template(data)
			
		imageTemplate: (data) -> 
			Object.getPrototypeOf(this).imageTemplate = 
				_.template($('#ad-view-image').html())
			@imageTemplate(data)
	
		events:
			"click .delete-link"  : "_onDelete"
			"click .edit-link"    : "edit"
			"dblclick .show"      : "edit"
			"focusout .edit-input": "update"
			"keypress .edit-input": "_onKeyPress"
		
		initialize: ->
			@isEditing = false
			@model.bind('change', @render, this)
			@model.bind('destroy', @remove, this)
		
		render: ->
			data = @model.toJSON()
			#console.log data
			$(@el).html(@template(data))
			@text  = @$('.show p')
			@input = @$('.edit-input')
			@imageList = @$('.image-list')
			console.log @imageList
			if data.images?
				for img in data.images
					console.log img.name
					@imageList.append(@imageTemplate(img))
			return this
		
		remove: ->
			el = $(@el)
			el.slideUp ->	el.remove()
			return this
		
		edit: ->
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
			return this
		
		# private
		
		_onKeyPress: (e) -> 
			return true unless e.which is 13 
			@update()
			return false
	
		_onDelete: () ->
			$ee.trigger(AD_DELETE_L, @model)
			return false

	# AdList class #
	
	class AdList extends Backbone.Collection
		model: Ad
		url: AD_API_URL

	# AdListView class #
	
	class AdListView extends Backbone.View
		
		initialize: () ->
			@list = @$('.ad-list')
		
		render: (ads) ->
			ads.each (ad) =>
				view = new AdView(model: ad)
				$(@el).prepend(view.render().el)
			return this

		renderOne: (ad) ->
			console.log 'AdListView::renderAd'
			view = new AdView(model: ad)
			li = $(view.render().el).hide()
			$(@el).prepend(li)
			li.slideDown()
			return this
		
	# AdBuilerView class #

	class AdBuilderView extends Backbone.View
	
		events: 
			"change .file-input"  : "_onFilesSelect"
			"click .submit-button": "build"
			"keyup .body-input"   : "_onKeyUp"
			"keypress .body-input": "_onKeyPress"
		
		initialize: ->
			_.bindAll(this, '_buildComplete')
			@uploader = new Uploader([], url: AD_UPLOAD_URL)
			@uploader.bind('add', @renderUpload, this)
			@bodyInput = @$('.body-input')
			@fileInput = @$('.file-input')
			@uploadList = @$('.upload-list')
			@submit  = @$('.submit-button')
			@counter = @$('.counter')
			
		setFilter: () ->
			return this
		
		renderUpload: (upload) ->
			view = new UploadView(model: upload)
			@uploadList.prepend($(view.render().el))
			upload.start()
			return this
		
		reset: ->
			@uploader.clear()
			@bodyInput.val('')
			@fileInput.val('')
			@counter.text(0)
			#@uploadList.html('')
	
		build: ->
			throw "already build" if @buildLock
			@buildLock = on
			@submit.attr(disabled: true)
			@fileInput.attr(disabled: true)
			@bodyInput.attr(disabled: true)
			@uploader.getResponses(@_buildComplete)
			return this
		
		# private
	
		_buildComplete: (responses) ->
			body = @bodyInput.val()
			@submit.removeAttr('disabled')
			@fileInput.removeAttr('disabled')
			@bodyInput.removeAttr('disabled')
			delete @buildLock
			images = []
			images.push(res.name) for res in responses
			$ee.trigger 'ad:build-complete.local',
				'body': body
				'images': images
			return this
		
	
		_onFilesSelect: ->
			files = []
			for file in @fileInput[0].files
				files.push('file': file) if @_filter(file)
			@uploader.add(files)
			return this
		
		_onKeyUp: (e) ->
			len = @bodyInput.val().length
			@counter.text(len)
			if len is 0
				@submit.attr(disabled: true)
			else
				@submit.removeAttr('disabled')
			return this
		
		_onKeyPress: (e) -> if e.which is 13 then @build(); false else true
		_filter: (file) -> return yes
	
	exports.Ad = Ad
	exports.AdList = AdList
	exports.AdView = AdView
	exports.AdListView = AdListView
	exports.AdBuilderView = AdBuilderView