module.exports = exports = ->
  doctype 5
  html ->
    head ->
      title 'Dashboard'
      meta charset: 'utf-8'
      link href: 'app.css', media: 'screen', rel: 'stylesheet', type: 'text/css'
      script @templates
      script src: 'app.js'
    body ->
      @body