#= require lang
#= require underscore

namespace "sellstome.common", (exports) ->
	SERVER_HOSTNAME = window.location.hostname
	REQUEST_PROTOCOL = window.location.protocol
	API_SERVER_HOSTNAME = SERVER_HOSTNAME
	API_PORT = 4000

	expandApiURL = ( relativePath ) ->
		throw new Error("Invalid argument") if not _.isString( relativePath )
		relativePath = "/" + relativePath if relativePath.indexOf("/") != 0
		expandedPath = REQUEST_PROTOCOL + "//" + API_SERVER_HOSTNAME + ":" + API_PORT + relativePath
		return expandedPath

	exports.expandApiURL = expandApiURL
