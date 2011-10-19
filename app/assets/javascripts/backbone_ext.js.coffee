#= require backbone
#= require underscore
# @param {Object} - hash of options passed to constructor
# @constructor

Backbone.Controller = (options) ->
  @cid = _.uniqueId('ctr')
  @initialize.call(this, options)
  return

_.extend Backbone.Controller.prototype, Backbone.Events,
  initialize: (options) -> return

#View that does not use dom at all
Backbone.DomlessView = (options) ->
  @cid = _.uniqueId('view');
  @_configure(options || {});
  @initialize.call(this, options);

#List of simple view options to be merged as properties.
viewOptions = ['model', 'collection', 'id', 'attributes'];

_.extend( Backbone.DomlessView.prototype, Backbone.Events, {

    initialize: ( options ) -> {}

    render: () ->
      return this

    remove: () ->
      return this

    _configure : (options) ->
      options = _.extend({}, this.options, options) if (this.options)
      for attr in viewOptions
        this[attr] = options[attr] if (options[attr])
      @options = options
})


Backbone.DomlessView.extend = Backbone.Controller.extend = Backbone.Router.extend