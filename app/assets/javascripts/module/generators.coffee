#= require lang
#= require underscore
#= require module/helpers

namespace "sellstome.generators", (exports) ->
	
	DEFAULT_CANVAS_WIDTH  = 300
	DEFAULT_CANVAS_HEIGHT = 150
	
	roundRect = (ctx, x, y, w, h, r, fill, stroke) ->
		if r > 0
			ctx.beginPath()
			ctx.moveTo(x + r, y)
			ctx.lineTo(x + w - r, y)
			ctx.quadraticCurveTo(x + w, y, x + w, y + r)
			ctx.lineTo(x + w, y + h - r)
			ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h)
			ctx.lineTo(x + r, y + h)
			ctx.quadraticCurveTo(x, y + h, x, y + h - r)
			ctx.lineTo(x, y + r)
			ctx.quadraticCurveTo(x, y, x + r, y)
			ctx.closePath()
		else
			ctx.rect(x, y, w, h)
		ctx.fill() if fill
		ctx.stroke() if stroke
	
	exports.generateCircle = (r, options) ->
		cfg = 
			fillStyle: 'white'
			strokeStyle: null
		_.extend(cfg, options)
		s = if cfg.strokeStyle? then 1 else 0
		canvas = document.createElement('canvas')
		canvas.width = 2*r+2*s
		canvas.height = 2*r+2*s
		ctx = canvas.getContext('2d')
		ctx.fillStyle = cfg.fillStyle if cfg.fillStyle?
		ctx.strokeStyle = cfg.strokeStyle if cfg.strokeStyle?
		ctx.arc(r+s ,r+s ,r , 0, 2*Math.PI, yes)
		ctx.fill() if cfg.fillStyle?
		ctx.stroke() if cfg.strokeStyle?
		return {
			width: canvas.width
			height: canvas.height
			anchorX: r+s
			anchorY: r+s
			shape: 
				coords: [r+s,r+s,r+s]
				type: 'circle'
			image: canvas.toDataURL("image/png") 
		}
		
	exports.generateRect = (w, h, options) ->
		cfg = 
			fillStyle: 'white'
			strokeStyle: null
			borderRadius: 0
		_.extend(cfg, options)
		s = if cfg.strokeStyle? then 1 else 0
		canvas = document.createElement('canvas')
		canvas.width = w + 2*s
		canvas.height = h + 2*s
		ctx = canvas.getContext('2d')
		ctx.fillStyle = cfg.fillStyle if cfg.fillStyle?
		ctx.strokeStyle = cfg.strokeStyle if cfg.strokeStyle?
		roundRect(ctx, s, s, w, h, cfg.borderRadius, 
		          cfg.fillStyle?,cfg.strokeStyle?)
		return {
			width: canvas.width
			height: canvas.height
			anchorX: Math.round(canvas.width/2)
			anchorY: Math.round(canvas.height/2)
			shape: 
				coords: [s, s, w + 2*s, h + 2*s]
				type: 'rect'
			image: canvas.toDataURL("image/png") 
		}
		
	exports.generatePriceBubble = (text, options) ->
		cfg = 
			font: '14px Georgia'
			color: 'black'
			fillStyle: 'white'
			strokeStyle: null
			paddingX: 5
			paddingY: 3
		_.extend(cfg, options)
		canvas = document.createElement('canvas')
		canvas.width  = DEFAULT_CANVAS_WIDTH
		canvas.height = DEFAULT_CANVAS_HEIGHT
		ctx = canvas.getContext('2d')
		ctx.font = cfg.font
		ctx.textBaseline = "top"
		ctx.fillText(text, 0, 0) 
		w = ctx.measureText(text).width
		# measure text height
		data = ctx.getImageData(0, 0, w, canvas.height).data
		state = i = h = h1 = h2 = 0
		while state < 2 and i < canvas.height
			if state is 0
				for j in [0...w]
					if data[w*i*4 + j*4 + 3] isnt 0
						h1 = i
						state++
						break
			else
				for j in [0...w]
					if data[w*i*4 + j*4 + 3] isnt 0
						break
					else if j is w - 1
						h2 = i
						state++
						break
			i++
		w += 2*cfg.paddingX
		h = h2 - h1 + 2*cfg.paddingY
		tailH = Math.round(h*0.4)
		tailW = Math.round(tailH/3)
		x = y = 0
		r = Math.round(h/5)
		canvas.width = w
		canvas.height = h + tailH
		# width setting resets the context, therefore define it again
		ctx.font = cfg.font
		ctx.textBaseline = "top"
		ctx.fillStyle = cfg.fillStyle if cfg.fillStyle?
		ctx.strokeStyle = cfg.strokeStyle if cfg.strokeStyle?
		ctx.beginPath()
		ctx.moveTo(x + r, y)
		ctx.lineTo(x + w - r, y)
		ctx.quadraticCurveTo(x + w, y, x + w, y + r)
		ctx.lineTo(x + w, y + h - r)
		ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h)
		ctx.lineTo(x + w/2 + tailW, y + h)
		ctx.lineTo(x + w/2, y + h + tailH)
		ctx.lineTo(x + w/2 - tailW, y + h)
		ctx.lineTo(x + r, y + h)
		ctx.quadraticCurveTo(x, y + h, x, y + h - r)
		ctx.lineTo(x, y + r)
		ctx.quadraticCurveTo(x, y, x + r, y)
		ctx.closePath()
		ctx.fill() if cfg.fillStyle?
		ctx.stroke() if cfg.strokeStyle?
		ctx.fillStyle = cfg.color
		ctx.fillText(text, cfg.paddingX, cfg.paddingY-h1)
		return {
			width: canvas.width
			height: canvas.height
			anchorX: Math.round(w/2)
			anchorY: Math.round(h + tailH)
			shape: 
				coords: [0, 0, w, h]
				type: 'rect'
			image: canvas.toDataURL("image/png") 
		}