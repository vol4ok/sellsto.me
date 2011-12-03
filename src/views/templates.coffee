module.exports = exports = 
  UIAdEntry: -> 
    div '.row', ->
      div '.col.image', ->
        img src: 'http://localhost:4000/images/m/<%= images[0].name %>.<%= images[0].type %>', alt: ''
      div '.col.content', ->
        div '.message', '<%= body %>'
        a href: '#', rel: 'twipsy', title: 'Some title text', 'Twipsy-test'
      div '.col.price', ->
        div '.price-data', '<sup>$</sup><%= price %>'
        div '.items-count', '<%= count %> items'
  UISpinner: ->  
    span '.spin-1', 'Loading...'
  UITooltip: ->
    div '.arrow', ''
    div '.inner', '<%= title %>'
  UIСurrencyPopover: ->
    div '.arrow', ''
    div '.inner', ->
      ul ->
        li -> a href: '#', '$'
        li -> a href: '#', '£'
        li -> a href: '#', '€'
        li -> a href: '#', 'руб.'