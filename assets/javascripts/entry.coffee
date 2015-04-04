###
**Frontend Javascript App**
---------------------------
This file bootstraps the front-end app. Javascript execution begins from here.
The App is heavily dependent on BackBone, Underscore and jQuery.

The App is designed with an MVC framework in mind although with Backbone, your
views become your controller. The App also contains *modules*, which are
components that do different things like routing/caching.

Read the comments at the end of the page if you are trying to trace how the
application works
###

###
## *window.App*
This variable is particularly important because it contains all the bits and
pieces of our App. Even the application's running instance!

This variable is made global so that different components of the App have a
uniformed way of accessing different components/resources.
###
window.App =
  Router: (require "app-controllers").router
  Cache: (require "app-controllers").cache
  ViewManager: (require "app-controllers").viewManager

  Resources:
    Library: require "app-libs"
    Config: require "app-config"
    Models: require "app-models"
    Views: require "app-views"
  instance: null


class Main
  constructor: (App) ->
    @initializeResources()
    @initializeViews()
    @initializeListeners()
    @initializeBackBone()

  initializeViews: ->
    @viewManager = new App.ViewManager @resources

  initializeListeners: ->
    _.extend @, Backbone.Events


  ###
  ## *initializeBackBone():*

  This function initialize Backbone by starting the router and modifying it's
  sync function.
  ###
  initializeBackBone: ->
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

    # Start Backbone history to trigger the different routes and to load
    # the first route.
    Backbone.history.start()


  initializeResources: ->
    @resources = App.Resources

    @resources.cache = new App.Cache
    @resources.categories = new App.Resources.Models.categories
    @resources.currentUser = new App.Resources.Models.user
    @resources.locations = new App.Resources.Models.locations
    @resources.router = new App.Router

    @resources.categories.resources = @resources
    @resources.locations.resources = @resources
    @resources.currentUser.resources = @resources

    @resources.categories.fetch()
    @resources.locations.fetch()
    @resources.currentUser.fetch()

###
**Main Javascript Execution starts here**
###
onDeviceReady = ->
  # Hide splash screen
  if window.Cordova and navigator.splashscreen
    navigator.splashscreen.hide()

  # Startup Foundation
  console.log '[foundation] initializing'
  ($ document).foundation()

  # Startup the App
  window.App.instance = new Main window.App
document.addEventListener "deviceready", onDeviceReady, false