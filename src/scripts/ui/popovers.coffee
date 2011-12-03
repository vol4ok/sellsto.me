#require ui/base
#require helpers

namespace "sm.ui", (exports) ->
  
  {ui,helpers} = sm
  {UIView} = ui
  
  class UIPopable extends UIView
    initialize: ->
      super()
      @target = $(@options.target)
      console.log @cid, @target
      @holder = $("##{@options.holderId}")
      @holder = @_createHolder() if @holder.length is 0
      @transitionEnd = helpers.getTransitionEnd()
      @state = {disabled: no, active: no}
      @render = getTemplate(@options.template)
      @options.data = _.extend {}, @options.data, @target.data()
      $(@el).html(@render(@options.data))

    _createHolder: ->
      return $(document.createElement('DIV'))
        .attr('id', @options.holderId)
        .css(position: 'absolute',top: 0,left: 0,bottom: 0,right: 0)
        .prependTo(document.body)

    _calculatePlacement: (p) ->
      tr = _.extend {}, @target.offset(), 
        width:  @target[0].offsetWidth
        height: @target[0].offsetHeight    
      tr.right  = tr.left + tr.width
      tr.bottom = tr.top  + tr.height
      w = @el.offsetWidth
      h = @el.offsetHeight
      if @options.autoplacement
        wr = 
          top: $(window).scrollTop()
          left: $(window).scrollLeft()
          width: $(window).width()
          height: $(window).height()
        wr.right  = wr.left + wr.width
        wr.bottom = wr.top  + wr.height
        t = tr.top - wr.top
        r = wr.right - tr.right
        b = wr.bottom - tr.bottom
        l = tr.left - wr.left
        ow = Math.max((w - tr.width) / 2, 0)
        oh = Math.max((h - tr.height) / 2, 0)
        ff = [ t > h, r > w, b > h, l > w ]
        k = 0
        for f in ff
          k <<= 1
          k |= if f then 1 else 0

        p2n = {above: 8, right: 4, below: 2; left: 1}
        k &= ~p2n[fp] for fp in @options.forbiddenPlacement when p2n[fp]?        
        pn = p2n[p]

        p = switch k
          when 7  then (if pn & 5 and t > oh then p else 'below')           #0111
          when 3  then (if r > w or r-ow >= t-oh then 'below' else 'left')  #0011
          when 11 then (if pn & 10 and r > ow then p else 'left')           #1011    
          when 9  then (if r > w or r-ow >= b-oh then 'above' else 'left')  #1001
          when 13 then (if pn & 5 and b > oh then p else 'above')           #1101     
          when 12 then (if l > w or l-ow >= b-oh then 'above' else 'right') #1100
          when 14 then (if pn & 10 and l > ow then p else 'right')          #1110    
          when 6  then (if l > w or l-ow >= t-oh then 'below' else 'right') #0110
          when 8  then 'above'
          when 4  then 'right'
          when 2  then 'below'
          when 1  then 'left'
          when 5  then (if pn & 5 then p else 'right')  #0101
          when 10 then (if pn & 10 then p else 'above') #1010
          when 0 then false
          else p
      o = switch p
        when 'below'
          top:  tr.bottom + @options.offset
          left: tr.left + (tr.width - w) / 2
        when 'above'
          top:  tr.top - h - @options.offset
          left: tr.left + (tr.width - w) / 2
        when 'left'
          top:  tr.top + (tr.height - h) / 2
          left: tr.left - w - @options.offset
        when 'right'
          top:  tr.top + (tr.height- h) / 2
          left: tr.right + @options.offset
        else {}
      return [o,p]

    show: -> 
      el = $(@el)
      el
        .remove()
        .attr('class', @className)
        .prependTo(@holder)
      el.addClass('fade') if @options.animate
      [offset, placement] = @_calculatePlacement(@options.placement)
      return unless placement
      el
        .css(offset)
        .addClass(placement)
        .addClass('in')
      @state.active = yes
    hide: ->
      el = $(@el)
      el.removeClass('in')
      if @transitionEnd? and @options.animate
        el.bind @transitionEnd, => el.remove()
      else
        el.remove()
      @state.active = no
    enable: ->
      @state.disabled = no;
    disable: ->
      @state.disabled = yes;
      @state.active = no
      @hide()

  ### ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ###

  class UITooltip extends UIPopable
    tagName: 'div'
    className: 'tooltip'
    defaults:
      animate: yes
      delayIn: 0
      delayOut: 0
      autoplacement: yes
      placement: 'above'
      live: yes
      offset: 0
      trigger: 'hover'
      template: 'UITooltip'
      target: null
      holderId: 'popover-holder'
      data: {}
      forbiddenPlacement: []
    initialize: (options) ->
      @options = _.extend {}, @defaults, options
      super()
      @state.hover = no
      binder   = if @options.live then 'live' else 'bind'
      eventIn  = if @options.trigger is 'hover' then 'mouseenter' else 'focus'
      eventOut = if @options.trigger is 'hover' then 'mouseleave' else 'blur'
      @target[binder](eventIn,  _.bind(@on_enter, this))
      @target[binder](eventOut, _.bind(@on_leave, this))
      #@target.data('tooltip', this)
    on_enter: ->
      return if @state.disabled
      @state.hover = yes
      if @options.delayIn
        setTimeout (=> @show() if @state.hover), @options.delayIn
      else
        @show() 
    on_leave: ->
      return if @state.disabled
      @state.hover = no
      if @options.delayOut
        setTimeout (=> @hide() unless @state.hover), @options.delayOut
      else
        @hide()

  ### ********************************************************************** ###

  class UIPopover extends UIPopable
    tagName: 'div'
    className: 'popover'
    defaults:
      animate: yes
      dynamic: yes
      delayIn: 0
      delayOut: 0
      autoplacement: yes
      placement: 'above'
      offset: 0
      trigger: 'hover'
      template: 'UIPopover'
      target: null
      holderId: 'popover-holder'
      forbiddenPlacement: []
    initialize: (options) ->
      @options = _.extend {}, @defaults, options
      super()
      @target.click _.bind(@on_click, this)
      #@target.data('tooltip', this)
    show: ->
      super()
      $('html').one 'click', (e) => @hide()
      $(@el).click (e) -> e.stopPropagation()
    on_click: (e) ->
      return if @state.disabled
      if @state.active
      then @hide() 
      else @show()
      e.stopPropagation()
      
  exports extends {UIPopable, UITooltip, UIPopover}