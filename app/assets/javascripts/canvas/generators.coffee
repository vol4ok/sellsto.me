#= require lang
#= require helpers

namespace "sellstome.generators", (exports) ->
	
	roundRect = (ctx,x,y,w,h,r,fill,stroke) ->
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
	
	exports.generateCircle = (r,fillColor = true,strokeColor = null) ->
		canvas = document.createElement('canvas')
		canvas.width = 2*r
		canvas.height = 2*r
		ctx = canvas.getContext('2d')
		ctx.fillStyle = fillColor if typeof fillColor is 'string'
		ctx.strokeStyle = strokeColor if typeof strokeColor is 'string'
		ctx.arc(r,r,r,0,2*Math.PI, yes)
		ctx.fill() if fillColor?
		ctx.stroke() if strokeColor?
		return canvas.toDataURL("image/png")
		
	exports.generateRect = (w, h, r = 0, fillColor = true,strokeColor = null) ->
		canvas = document.createElement('canvas')
		canvas.width = w
		canvas.height = h
		ctx = canvas.getContext('2d')
		ctx.fillStyle = fillColor if typeof fillColor is 'string'
		ctx.strokeStyle = strokeColor if typeof strokeColor is 'string'
		roundRect(ctx, 0,0,w,h,r,fillColor?,strokeColor?)
		return canvas.toDataURL("image/png")
		
	exports.generatePriceBubble = (price,fillColor = true, strokeColor = null) ->
		canvas = document.createElement('canvas')
		ctx = canvas.getContext('2d')
		ctx.font = '14px Georgia'
		ctx.textBaseline = "top"
		w = ctx.measureText(price).width + 6
		canvas.width = w
		canvas.height = 24
		h = 18
		x = y = 0
		r = 4
		ax = x + w/2
		ay = y + h + 6
		shape = 
			coords: [0,0,w,h]
			type: 'rect'
		ctx.font = '14px Georgia'
		ctx.textBaseline = "top"
		ctx.fillStyle = fillColor if typeof fillColor is 'string'
		ctx.strokeStyle = strokeColor if typeof strokeColor is 'string'
		ctx.beginPath()
		ctx.moveTo(x + r, y)
		ctx.lineTo(x + w - r, y)
		ctx.quadraticCurveTo(x + w, y, x + w, y + r)
		ctx.lineTo(x + w, y + h - r)
		ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h)
		ctx.lineTo(x + w/2 + 2, y + h)
		ctx.lineTo(x + w/2, y + h + 6)
		ctx.lineTo(x + w/2 - 2, y + h)
		ctx.lineTo(x + r, y + h)
		ctx.quadraticCurveTo(x, y + h, x, y + h - r)
		ctx.lineTo(x, y + r)
		ctx.quadraticCurveTo(x, y, x + r, y)
		ctx.closePath()
		ctx.fill() if fillColor?
		ctx.stroke() if strokeColor?
		ctx.fillStyle = '#444'
		ctx.fillText(price, 3, 0)
		return {
			width: canvas.width
			height: canvas.height
			anchorX: ax
			anchorY: ay
			shape: shape
			image: canvas.toDataURL("image/png") 
		}