# EXPLAIN CONTROLLER HERE
#
# This way, we can avoid having the server returning huge responses which
# contain HTML code and instead have the server communicate with JSON
# objects which contain data.
module.exports = class controller
	name: '[controller:localstorage]'
	fallback: false

	# Checks the JS version from the server side and setups the local storage
	# based on it. If the JS version from the local and the server are
	# different, then reset the local storage. Otherwise have the local storage
	# cache every page template that it downloads.
	#
	# Also, if the browser does not support localStorage use fallback methods.
	constructor: (app, @config) ->
		console.log @name, 'initializing'

		# Check if localStorage is supported
		if not Storage?
			# Setup fallback methods
			@fallback = true
			console.log @name, 'HTML5 Storage not supported. Using fallback methods'
			console.warn @name, 'no fallback methods for localstorage have been implemented so far'

	# Function to store a key-string pair into the cache
	cache: (key, string) ->
		if @fallback then return

		console.log @name, "setting '#{key}' into cache"
		localStorage.setItem key, string


	# Function to get a key-string pair from the cache, given the key
	get: (key) ->
		if @fallback then return

		console.log @name, "retrieving '#{key}' from cache"
		localStorage.getItem key