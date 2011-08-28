#=require backbone
#=require underscore
Backbone.Controller = ()->
	this.initialize.apply(this)
	return

#Set up all inheritable **Backbone.Controller** properties and methods.
_.extend(Backbone.Controller.prototype, Backbone.Events, {
	initialize: () ->
		return
})

Backbone.Controller.extend = Backbone.Router.extend