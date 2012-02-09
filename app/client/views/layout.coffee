module.exports = exports = ->
  doctype 5
  html ->
    head ->
      title 'Sellsto.me'
      meta charset: 'utf-8'
      link href: '/css/app.css', media: 'screen', rel: 'stylesheet', type: 'text/css'
      link href: '/css/leaflet-latest/leaflet.css', media: 'screen', rel: 'stylesheet', type: 'text/css'
      script @templates
      script src: '/js/app.js'
    body ->
      @body