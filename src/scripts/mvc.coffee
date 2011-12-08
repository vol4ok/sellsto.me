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
      
  class View extends Backbone.View
    initialize: (options) ->
      registerObject(@cid, this)
  class Model extends Backbone.Model
  class Collection extends Backbone.Collection
  class Router extends Backbone.Router
    initialize: (options) ->
      registerObject(@cid, this)
  
  exports extends {Controller, View, Model, Collection, Router}