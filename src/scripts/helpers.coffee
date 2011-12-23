namespace "sm.helpers", (exports) ->
  
  getTransitionEnd = () ->
    thisBody = document.body or document.documentElement
    thisStyle = thisBody.style
    support = thisStyle.transition != undefined || 
      thisStyle.WebkitTransition != undefined || 
      thisStyle.MozTransition != undefined || 
      thisStyle.MsTransition != undefined || 
      thisStyle.OTransition != undefined
    if support
      transitionEnd = "TransitionEnd"
      if $.browser.webkit
        transitionEnd = "webkitTransitionEnd"
      else if $.browser.mozilla
        transitionEnd = "transitionend"
      else if $.browser.opera
        transitionEnd = "oTransitionEnd"
      return transitionEnd
    return false

  class UrlBuilder
    ### whenever this url uses https ###
    isSecure: false
    domain:   null
    port:     null
    path:     ""
    ### collection of key-value pairs ###
    params:   null

    ### todo zhugrov a - perform validation of input arguments ###
    constructor: (options) ->
      @isSecure  = options.isSecure if  options.isSecure?
      @domain    = options.domain   if  options.domain?
      @port      = options.port     if  options.port?
      @path      = options.path     if  options.path?
      @params    = new Array()
      return

    on: (name, value) ->
      @params.push(name: name, value: value)
      return this

    url: ->
      throw new Error("Domain is not set") if _.isNull(@domain)
      url =  if @isSecure then "https://" else "http://"
      url += @domain
      url += ":" + @port if not _.isNull(@port)
      url += @path
      query = new Array()
      for param in @params
        query.push(encodeURIComponent(param.name) + "=" + encodeURIComponent(param.value)) if param.name? and param.value?
      url += "?" + query.join("&") if not _.isEmpty(query)
      return url

    
  exports extends {getTransitionEnd,UrlBuilder}