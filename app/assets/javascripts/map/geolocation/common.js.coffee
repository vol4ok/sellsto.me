# This is file that would be used as geolocation wrapper
# The first implementation would be based on w3c HTML5 geolocation implementation

namespace "sellstome.geolocation", (() ->
  #Import section
  GeolocationRequest = () ->
    if not navigator.geolocation
      throw new Error "Geolocation is un-available for your browser"

  GeolocationRequest.prototype.getCurrentPosition = ( callback , errorCallback , options ) ->
    if callback? and errorCallback? and options?
      navigator.geolocation.getCurrentPosition callback, errorCallback, options
    else if callback? and errorCallback?
      navigator.geolocation.getCurrentPosition callback, errorCallback
    else
      navigator.geolocation.getCurrentPosition callback

  #Public members
  return {
    GeolocationRequest: GeolocationRequest
  }
)()