# EXPLAIN CONTROLLER HERE
#
# This way, we can avoid having the server returning huge responses which
# contain HTML code and instead have the server communicate with JSON
# objects which contain data.
module.exports = class controller
  name: '[cache]'
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
    if Storage?
      # @checkVersions()

      # Cache the startup scripts for the next time the user visits the
      # site
      # @cacheStartupScripts()

    else
      # Setup fallback methods
      @fallback = true
      console.log @name, 'HTML5 Storage not supported. Using fallback methods'
      console.warn @name, 'no fallback methods for cache have been implemented so far'


  checkVersions: ->
    # return
    console.log @name, "checking cache version"
    magic = window.config.magic or {}

    if (@get 'magic:library') != magic.library
      console.log @name, "library caches differ, clearing"

      @clearLibrariesCache()
      @set 'magic:library', magic.library

    if (@get 'magic:models') != magic.models
      console.log @name, "model caches differ, clearing"

      @clearModelsCache()
      @set 'magic:models', magic.models

    if (@get 'magic:application') != magic.application
      console.log @name, "application caches differ, clearing"

      @clearApplicationCache()
      @set 'magic:application', magic.application


  clearApplicationCache:  -> @removeKeysHelper 'app'
  clearLibrariesCache:    -> @removeKeysHelper 'library'
  clearModelsCache:       -> @removeKeysHelper 'models'
  removeKeysHelper: (tag) ->
    keysToRemove = []
    for i in [0...localStorage.length]
      key = localStorage.key i
      if key? and ((key.split ':')[0] == tag) then keysToRemove.push key
    localStorage.removeItem key for key in keysToRemove

  # This function is responsible for saving all the startup scripts
  # (eg: jQuery, Backbone, Masonry) into the localStorage cache. This way the
  # next time the user open the page, site will immediately load the scripts
  # from the cache and avoid making requests from the CDN.
  #
  # The code that loads the script that is saved in the local path of the app.
  # This is done, because most browsers don't allow cross-browser requests
  # and saving the scripts local is a solution for this.
  cacheStartupScripts: ->
    if @fallback then return

    # The list of scripts is accessible to us by the global variable
    # 'scripts'
    for script in scripts
      storageIdentifier = script.name

      # Check if the script already exists in the cache
      if script.localSrc? and not @get storageIdentifier
        console.log @name, "caching script:", script.name

        # Start fetching the local version of the script asynchronously.
        # and save it into the cache.
        ajax = (storageIdentifier, script) =>
          $.ajax
            url: script.localSrc,
            success: (result) =>
              @set storageIdentifier, result
              console.log @name, "cached script:", storageIdentifier

        ajax storageIdentifier, script


  # Saves the HTML template of the current view in the HTML5 local-storage.
  # This gets treated as cache and will get loaded the next time the view
  # has been requested. The HTMLs that gets cached is whatever HTMLs code that
  # lies inside the current-view, under the '.html-cache' class
  #
  # Ideally, we would want to put code that never changes in those tags; eg.
  # Underscore templates.
  cacheView: (view, identifier) ->
    if @fallback then return

    # Get the view identifier
    storageIdentifier = 'app:page-' + identifier

    # Check if this view has been cached or not
    if @get(storageIdentifier) then return

    # If we reach here, then get the HTML we need to cache and store it
    console.log @name, 'saving current view to cache'
    html = view.$el.find('.html5-cache').html()

    # Avoid caching empty html
    if !html or html == ''
      return console.warn(@name, 'nothing was cached')

    # If all went well, save the html
    @set storageIdentifier, html


  # This function returns the HTML code (if any) that is cached in the local
  # storage.
  getCachedViewHTML: (identifier) ->
    if @fallback then return
    storageIdentifier = @get('app:page-' + identifier)

    if storageIdentifier then console.log @name, 'fetched HTML from cache'
    storageIdentifier


  # Function to store a key-string pair into the cache
  set: (key, string) ->
    if @fallback then return

    console.log @name, "setting '#{key}' into cache"
    localStorage.setItem key, string


  # Function to get a key-string pair from the cache, given the key
  get: (key) ->
    if @fallback then return

    console.log @name, "retrieving '#{key}' from cache"
    localStorage.getItem key