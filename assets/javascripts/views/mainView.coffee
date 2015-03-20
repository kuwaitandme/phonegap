# This is the base view for all pages in the app; ie. All pages must inherit
# the properties in the view. The different functions and properties defined
# here get used by the ViewManager controller and enables the controller to
# neatly cleanup and restart views.
module.exports = Backbone.View.extend
	initialize: (@options) ->
		self = @

		# These are events that get called by the ViewManager controller. You
		# don't have to explicitly trigger them but just ensure that all your
		# code lies in the functions defined the next section.
		@on 'start', -> self.start self.options
		@on 'continue', ->
			self.$el.show()
			self.undelegateEvents()
			self.delegateEvents()
			self.continue()
		@on 'pause', () ->
			self.undelegateEvents()
			self.pause()
			self.$el.hide()
		@on 'finish', ->
			self.finish()
			self.remove()
		@on 'redirect', -> self.redirect()


	# Her goes the name of the view. This is used in console.log statements
	# to help debug the app. So in your view you would use something like
	# > console.log @name, "Message"
	# and this makes it easy to filter out console messages generated by that
	# view. (Since the app generates alot of console messages)
	name: ""


	# These functions control the view state. These functions are never called
	# directly. Instead events are sent to the view which then triggers the
	# functions accordingly.
	#
	# start() is called once, when the app is initializing the view.
	# continue() is called everytime the app wants to restart the view.
	# pause() is called when the app wants to temporarily switch to another view
	# finish() is called when the app wants to finally kill the view.
	start:    -> console.log @name, "starting"
	continue: -> console.log @name, "continuing"
	pause:    -> console.log @name, "pausing"
	finish:   -> console.log @name, "finishing"


	# These two functions decide if the App's control has to be redirected or
	# not.
	#
	# checkRedirect() is used to see if the app's control has to be redirected
	# and redirect is the function that performs the redirection.
	checkRedirect: -> false
	redirect: ->

	# Function to redirect to the router's goto fn.
	goto: (url, view, args) -> app.controllers.router.goto url, view, args