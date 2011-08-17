# events: start, progress, finish abort, error, state-change
class Upload extends Backbone.Model
	initialize: (attrs, options) ->
		_.bindAll(this, '_onStart', '_onStateChange', '_onProgress', 
										'_onFinish', '_onAbort', '_onError')
		@xhr = new XMLHttpRequest()                                
		@xhr.onreadystatechange = @_onStateChange
		@xhr.onloadstart = @_onStart
		@xhr.onload = @_onFinish
		@xhr.onabort = @_onAbort
		@xhr.onerror = @_onError
		@xhr.upload.onprogress = @_onProgress
		
	start: ->
		console.log 'send', @attributes.file.type
		@xhr.open("POST", @url(), true)
		@xhr.setRequestHeader("Content-Type", @attributes.file.type)
		@xhr.send(@attributes.file)
		return this
		
	abort: ->	
		@xhr.abort()
		return this
		
	destroy: ->
		console.log 'Upload destroy'
		@xhr.abort() if @xhr.readyState < 4
		return super()
		
	sync: -> return false # prevent default sync methods
	
	# private

	_onStateChange: -> 
		@trigger('state-change', this, @xhr.readyState)
		return this
		
	_onStart: ->	
		@trigger('start', this); 
		return this
		
	_onProgress: (e) ->
		if @isLengthComputable = e.lengthComputable
			@loaded = e.loaded
			@total  = e.total
		@trigger('progress', this)
		return this
		
	_onAbort: ->	
		@trigger('abort', this); 
		return this
		
	_onError: ->
		@trigger('error', this); 
		return this
		
	_onFinish: (e) ->
		if @isLengthComputable = e.lengthComputable
			@loaded = e.loaded
			@total  = e.total
		res = JSON.parse(@xhr.responseText)
		@set(response: res)
		@trigger('finish', this, res)
		return this
		
class Uploader extends Backbone.Collection
	model: Upload
	initialize: (models, options) ->
		@url = options.url if options.url?
		@activeCount = 0
		@callbackList = []
		@bind('add', @_onAdd, this)
		
	sync: -> return false # prevent default sync methods
	
	getResponses: (callback) ->
		@callbackList.push(callback)
		console.log 'getResponses'
		@_getResponses() if @activeCount is 0
		return this
		
	clear: ->
		@models[0].destroy() while @models.length isnt 0
		return this
			
	# private

	_onAdd: (upload) ->
		@activeCount++
		console.log "add [#{@activeCount}]"
		upload.bind('finish', @_onFinish, this)
		return this
		
	_onFinish: (upload, res) ->
		upload.unbind('finish', @onFinish)
		@activeCount--
		console.log "finish [#{@activeCount}]"
		if @activeCount is 0
			@trigger('finish', this) 
			console.log 'complete'
			@_getResponses()
		return this
		
	_getResponses: ->
		if @callbackList.length > 0
			responses = @pluck('response')
			console.log 'Complete getResponses!', responses
			while @callbackList.length isnt 0	
				callback = @callbackList.pop()
				callback(responses)
		return this
			
	
class UploadView extends Backbone.View
	
	tagName: 'li'
	# template: _.template($('#upload-view').html())
	
	events:
		"click .remove-link" : "_onRemove"
		
	initialize: ->
		@model.bind('start', @_onStart, this)
		@model.bind('progress', @_onProgress, this)
		@model.bind('finish', @_onFinish, this)
		@model.bind('destroy', @remove, this)
		
	render: ->
		$(@el).html(@template(@model.toJSON()))
		@progress = @$('.progress')
		return this
		
	# private

	_onStart: (upload) ->
		if upload.isLengthComputable
			@progress.text("0%")
			@progress.show()
		return this
		
	_onProgress: (upload) ->
		if upload.isLengthComputable
			progress = Math.round(100 * upload.loaded / upload.total)
			@progress.text("#{progress}%")
		return this
		
	_onFinish: (upload) ->
		@progress.hide()
		return this
		
	_onRemove: () ->
		return this
		
@Upload = Upload
@Uploader = Uploader
@UploadView = UploadView