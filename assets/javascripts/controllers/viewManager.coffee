module.exports = class viewManager
	name: '[viewManager]'

	components:  (require 'app-views').components
	pages:       (require 'app-views').pages

	viewBuffer: []

	# Setup the different views. ie. Initialize the different controllers for
	# the header, currentView and other components.
	constructor: (@config) ->
		console.log @name, 'initializing'

		# Cache some DOM variables
		@$body           = $ 'body'
		@$currentPage    = $ '#current-page'
		@$nextPage       = $ '#next-page'
		@$previousPage   = $ '#prev-page'
		@$ptMain         = $ 'main'

		# Render different components
		@header = new (@components.header)(el: 'header')
		@messages = new (@components.messages)(el: '#messages')
		@progressBar = new @components.progressBar


	start: ->
		self = @

		# Attach different listeners
		@header.currentUser = @models.currentUser
		@models.currentUser.on 'sync', -> self.header.update()
		@router.on 'change', (args) -> self.routeHandle args


	routeHandle: (args={}) ->
		viewIdentifier = args.view
		historyState = args.state

		console.log @name, "setting view to:", viewIdentifier
		console.debug @name, "using history:", historyState

		@setView viewIdentifier, historyState

		# ($ document).foundation 'clearing', 'reflow'

		# Signal the header to update itself
		@header.update()


	# Set's the currentView with all the proper animations and DOM
	# manipulations.
	setView: (viewIdentifier, historyState={}) ->
		# Check if there was a view before, and if there was then switch the pages
		if @currentView? then @switchPages viewIdentifier, historyState
		else @initPage viewIdentifier, historyState

		# Attach the basic models to the view
		@currentView.currentUser = @models.currentUser
		@currentView.categories = @models.categories
		@currentView.locations = @models.locations

		# Check for any redirection
		if @currentView.checkRedirect()
			return @router.redirect @currentView.redirectUrl()

		# Now signal the view to manipulate the DOM.
		@currentView.trigger 'continue'



	initPage: (targetViewIdentifier, historyState) ->
		console.log @name, 'initializing first view'
		@currentViewName = targetViewIdentifier

		targetView = @getView targetViewIdentifier
		url = document.URL
		index = historyState.index

		$el = $ '.pt-page'
		$el.attr 'data-index', index
		$el.attr 'data-url', url

		# Load set the currentView directly without any transitioning
		@currentView = new targetView
			args: historyState
			el: ".pt-page[data-url='#{url}'][data-index='#{index}']"

		# Save the view in our buffer
		@viewBuffer.push @currentView

		# Start the view
		@currentView.trigger 'start'


	findTargetView: (historyState) ->
		console.log @name, "trying to find view in buffer"
		index = historyState.index
		url = document.URL

		for view in @viewBuffer
			if view? and view.$el? and
			(view.$el.data 'url') is url and
			(view.$el.data 'index') is index
				console.log @name, "view found in buffer. reusing view"
				return view


	createTargetView: (targetViewIdentifier, historyState) ->
		console.debug @name, "creating new view", targetViewIdentifier

		index = historyState.index
		url = document.URL#historyState.arguments.url

		$targetPage = $ "<div data-url='#{url}' data-index='#{index}'></div>"
			.addClass 'pt-page'
			.addClass targetViewIdentifier

		# Add the HTML into the DOM
		@$ptMain.append $targetPage

		view = @getView targetViewIdentifier
		targetView = new view
			args: historyState
			el: ".pt-page[data-url='#{url}'][data-index='#{index}']"

		# Save the view in our buffer and return
		@destroyUnwantedViews index
		@viewBuffer.push targetView
		targetView


	switchPages: (targetViewIdentifier, historyState) ->
		# Clean up the view before switching to the next one. Detach
		# all event handlers and signal the view to run any 'closing'
		# animations.
		@currentViewName = targetViewIdentifier

		# Read the history state to see if we are moving backward or
		# forward.
		reverse = historyState.reverse or false

		# Pause current page
		@currentView.trigger 'pause'

		targetView = @findTargetView historyState

		if not targetView
			console.debug @name, "view not found", targetViewIdentifier

			# Create a new view
			targetView = @createTargetView targetViewIdentifier, historyState

			# start target view
			targetView.trigger 'start'

		@currentView = targetView


	# Finds the view with the given name and returns it's object.
	getView: (viewIdentifier) -> @pages[viewIdentifier]


	destroyUnwantedViews: (historyIndex) ->
		index = 0
		for view in @viewBuffer
			if not view? or not view.$el? then continue
			viewIndex = Number view.$el.data 'index'

			# Destroy views that are in forward of history and those that are
			# to far behind in history.
			if viewIndex is historyIndex or (historyIndex - viewIndex) > 5
				@viewBuffer[index] = null
				view.trigger 'finish'
			index += 1