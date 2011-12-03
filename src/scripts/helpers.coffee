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
    
  exports extends {getTransitionEnd}