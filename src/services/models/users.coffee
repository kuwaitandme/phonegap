exports = module.exports = ($environment, $http, $log, $root, $storage) ->
  new class
    name: "[model:user]"

    roles:
      NORMAL:    0
      MODERATOR: 1
      ADMIN:     2

    statuses:
      INACTIVE:   0
      ACTIVE:     1
      BANNED:     2
      SUSPENDED:  3

    setCurrentUser: (user) -> $storage.session "models:user:current", angular.toJson user
    getCurrentUser: -> (angular.fromJson $storage.session "models:user:current") or {}
    isLoggedIn: -> @getCurrentUser().id?

    constructor: ->
      $root.$on "user:changed", => @onUserChange()
      $root.bodyClasses ?= {}


    onUserChange: (user) ->
      @setCurrentUser user
      $root.bodyClasses["logged-in"] = @isLoggedIn()


    # Re-downloads the user from the server.
    refresh: ->
      $log.log @name, "refreshing current user"
      $http.get "#{$environment.url}/api/users/current"
      .success (user) =>
        $log.log @name, "refreshed current user"
        $log.debug @name, user
        @onUserChange user


    # A simple function to perform a user-logout. Deletes the current session
    # both locally and from the server.
    logout: ->
      $http.get "#{$environment.url}/api/auth/logout"
      .success (data, status) =>
        $log.log @name, "user logged out"
        @onUserChange null


    # Download the current user from either the sessionStorage or from the API
    download: ->
      # This helper function is used to get the user details from the API
      _fetchFromAPI = =>
        $log.log @name, "downloading user"
        $http.get "#{$environment.url}/api/users/current"
        .success (user) =>
          $log.log @name, "fetched current user"
          $log.debug @name, user
          @onUserChange user

      # Attempt to get the user from the cache.
      cache = $storage.session "models:user:current"
      if cache?
        # user was found in session cache, prepare to translate it and return
        $log.log @name, "retrieving current user from cache"
        try
          @onUserChange angular.fromJson cache
        catch exception
          # Something went wrong while parsing the locations. No problem,
          # we'll retrieve it from the API.
          _fetchFromAPI()
      else
        # locations were never saved. So retrieve it from the API.
        $log.log @name, "retrieving current user from API"
        _fetchFromAPI()


exports.$inject = [
  "$environment"
  "$http"
  "$log"
  "$rootScope"
  "$storage"
]