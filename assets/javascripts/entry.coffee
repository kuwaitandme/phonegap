if not window.app?
	# App entry point for the 'Kuwait & Me' project. This has been such an amazing
	# journey, although sad that I had to do it myself. This app that I have coded
	# below relies heavily on Backbone.js, jQuery and Underscore. Hope it interests
	# you to read through it..
	#
	# This file bootstraps the front-end app. Main JS execution begins here.
	class App
		constructor: ->
			console.log "[app] initializing"

			@config       = require "app-config"
			@controllers  = require "app-controllers"
			@helpers      = require "app-helpers"
			@libs         = require "app-libs"
			@models       = require "app-models"
			@views        = require "app-views"

			_.extend @, Backbone.Events

			# Initialize the components
			@controllers.initialize this, @config
			@models.initialize      this, @config
			@controllers.models = @models

			# Setup listeners
			@setupListeners()

		start: ->
			console.log "[app] starting"

			@models.start()
			@controllers.start()
			$(document).foundation()

		setupListeners: ->
			self = @
			@on 'redirect', (url) -> self.controllers.router.redirect url
			@on 'reload', -> self.controllers.router.reattachRouter()

window.app = new App
window.app.start()