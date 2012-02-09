#require vendor/underscore
#require vendor/backbone

namespace "sm.mvc", (exports) ->
  
  Controller = (options) ->
    @cid = _.uniqueId('ctr')
    @initialize.call(this, options)
    return

  _.extend Controller.prototype, Backbone.Events,
    initialize: (options = {}) -> 
      @cid = options.cid if options.cid?
      registerObject(@cid, this)
      @state = {}
      
  #List of simple view options to be merged as properties.
  VIEW_OPTIONS = ['model', 'collection', 'id', 'attributes'];
  
  DomlessView = (options) ->
    @cid = _.uniqueId('dview')
    @_configure(options || {})
    @initialize.call(this, options)
    return
  _.extend DomlessView.prototype, Backbone.Events,
    initialize: (options = {}) -> 
      @cid = options.cid if options.cid?
      registerObject(@cid, this)
      @state = {}
    _configure: (options) ->
      options = _.extend({}, @options, options) if @options
      for attr in VIEW_OPTIONS
        this[attr] = options[attr] if options[attr]
      @options = options
      
  class View extends Backbone.View
    initialize: (options) ->
      registerObject(@cid, this)
      @state = {}
  class Model extends Backbone.Model
  class Collection extends Backbone.Collection
  class Router extends Backbone.Router
    initialize: (options) ->
      registerObject(@cid, this)
  
  exports extends {Controller, View, DomlessView, Model, Collection, Router}