#= require lang
#= require underscore
#= require jquery
# This file would be used for implementing sellstome Google Map overlays
# We currently using v3 Google map javascript API
# @author Zhugrov Aliaksandr

namespace "sellstome.map", (exports) ->

	InfoWindow = ( options ) ->
		this.content = options.content
		# dom element that holds window dom representation
		this.container = null
		# @type: google.maps.LatLng
		this.position = null
		return

	_proto = InfoWindow.prototype = new google.maps.OverlayView()

	#redefine functions that are called by Google Map API

	_proto.onAdd = () ->
		container = document.createElement "div"
		jQuery(container).html this.content
		this.container = container
		panes = this.getPanes()
		panes.floatPane.appendChild container
		return
	_proto.draw = () ->
		overlayProjection = this.getProjection()
		offsetPoint = overlayProjection.fromLatLngToDivPixel this.position
		container = this.container
		jQuery(container).css
			position: "absolute"
			left: offsetPoint.x
			top: offsetPoint.y
			background: "white"
			height: "60px"
			width: "130px"
		return
	_proto.onRemove = () ->
		jQuery(container).remove()
		this.container = null
		return

	#define other interface functions
	# @param anchor - currently the only supported anchor is google.maps.Marker
	_proto.open = (map, anchor) ->
		this.position = anchor.getPosition()
		this.setMap map
		return

	exports.InfoWindow = InfoWindow


namespace "sellstome.map", (exports) ->

	Canvas = ( options ) ->
		# dom element that holds window dom representation
		this.container = null
		this.options = options
		# set map and invokes initialization of element
		this.setMap options.map
		return

	_proto = Canvas.prototype = new google.maps.OverlayView()

	#redefine functions that are called by Google Map API

	_proto.onAdd = () ->
		container = document.createElement "canvas"
		this.container = container
		panes = this.getPanes()
		panes.overlayLayer.appendChild container
		ctx = container.getContext("2d")
		ctx.fillStyle = "rgb(200,0,0)"
		ctx.fillRect 10, 10, 55, 50
		return
	_proto.draw = () ->
		overlayProjection = this.getProjection()
		container = this.container
		offsetPoint = overlayProjection.fromLatLngToDivPixel this.options.position
		jQuery(container).css
			position: "absolute"
			left: offsetPoint.x
			top:  offsetPoint.y
			height: "300px"
			width: "300px"
		return
	_proto.onRemove = () ->
		jQuery(container).remove()
		this.container = null
		return

	exports.Canvas = Canvas


namespace "sellstome.map", (exports) ->
	###
	# @constructor
	# @extends google.maps.OverlayView
	###
	AdInfo = ( options ) ->
		@initialize( options )
		return

	_.extend AdInfo.prototype , new google.maps.OverlayView() ,
		#define object attributes

		###@type {google.map.Marker} ###
		anchor:       null
		###@type {google.map.LatLng}###
		position:     null
		###@type {string}###
		description:  null
		###@type {Object}###
		container:    null
		###@type {Object}###
		overlay:      null
		###
		# Actual google map instance
		# @type {google.map.Map}
		###
		map:          null

		initialize: ( options ) ->
			_.forEach( options , ( value , key ) =>
				if not _.isUndefined( value )
					if not _.isUndefined( @[key] ) and not _.isFunction( @[key] )
						@[key] = options[key]
			)
			if not _.isNull( @map )
				@setMap( @map ) #add overlay to map
			return this

		###this method is added just for convenience###
		removeFromMap: () ->
			@setMap(null)
			return this

		onAdd: () ->
			panes = this.getPanes()
			#create overlay
			overlay = document.createElement( 'div' )
			@overlay = overlay
			panes.floatShadow.appendChild( overlay )
			#create container
			container = document.createElement( 'div' )
			$( container ).html( @description )
			@container = container
			panes.floatPane.appendChild( container )
			# register appropriate event handlers
			$( container ).click (e) =>
				@removeFromMap()
			$( overlay ).click (e) =>
				@removeFromMap()
			return

		draw: () ->
			overlayProjection = @getProjection()
			if _.isNull( @position )
				@position = @anchor.getPosition()
			offsetPoint = overlayProjection.fromLatLngToDivPixel( @position )
			#todo - remember that we should minimize a dom access in order to gain a performance
			$( @container ).css
				position: 'absolute'
				left: offsetPoint.x
				top: offsetPoint.y
				background: 'white'
				height: '60px'
				width: '130px'
			#todo zhugrov a - all styling should be applied via css as much as possible
			$( @overlay ).css
				height:           $( @overlay ).parent().height()
				width:            $( @overlay ).parent().width()
				backgroundColor:  'black'
				opacity:          0.4
			return

		onRemove: () ->
			$( @container ).remove()
			@container = null
			$( @overlay ).remove()
			@overlay = null
			return

	exports.AdInfo = AdInfo