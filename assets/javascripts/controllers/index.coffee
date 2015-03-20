localStorage   = require './localStorage'
router         = require './router'
viewManager    = require './viewManager'

# Initializes each of the controllers one by one.
module.exports =
	name: '[controller]'

	initialize: (app, config) ->
		console.log @name, 'initializing'
		self = @

		# Rewrite backbone sync with our custom sync function. For now add our
		# little hack to bypass the CSRF token. NOTE that we must find another
		# way to have CSRF added into every AJAX call without having to making
		# more than one request.
		backboneSync = Backbone.sync
		newSync = (method, model, options) ->
			options.beforeSend = (xhr) ->
				# Set the captcha header
				captcha = ($ '[name="g-recaptcha-response"]').val()
				if captcha then xhr.setRequestHeader 'x-gcaptcha', captcha

				# Set the CSRF skipper
				xhr.setRequestHeader 'x-csrf-skipper'
			backboneSync method, model, options
		Backbone.sync = newSync

		@localStorage   = new localStorage app, config
		@viewManager    = new viewManager app, config
		@router         = new router app, config
		# window.a = @router

		@router.on 'change', (event) -> self.viewManager.routeHandle event
		Backbone.history.start()
		# @router.navigate('#')

	start: ->
		console.log @name, 'starting'
		@viewManager.start()