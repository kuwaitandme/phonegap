exports = module.exports = ($stateProvider, $locationProvider, $urlMatcher,
  $urlRouterProvider) ->

  # Enable strict mode to allow URLs with trailing slashes
  $urlMatcher.strictMode false

  # Helper function to create our routes
  index = 0
  _route = (page, route) ->
    $stateProvider.state "#{page}-#{index++}",
      controller: "#{page}"
      templateUrl: "views/#{page}/template"
      url: route
      resolve:
        categories: ["models.categories", (m) -> m.download()]
        user: ["models.users", (m) -> m.download()]
        location: ["models.locations", (m) -> m.download()]
        notifications: ["models.notifications", (m) -> m.download()]

  _route "index",                       ""
  _route "account",                     "/account"
  _route "account/classifieds",         "/account/classifieds"
  _route "account/classifieds/single",  "/account/classifieds/{id:[0-9]+}"
  _route "account/moderate",            "/account/moderate"
  _route "account/moderate/single",     "/account/moderate/{id:[0-9]+}"
  _route "auth",                        "/auth"
  _route "auth/logout",                 "/auth/logout"
  _route "classified/finish",           "/classified/finish/{id:[0-9]+}"
  _route "classified/create",           "/classified/create"
  _route "classified/category",         "/classified"
  _route "classified/search",           "/classified/{parent:[^/]+}"
  _route "classified/search",           "/classified/{parent:[^/]+}/{child:[^/]+}"
  _route "classified/single",           "/{slug:[^/]+}-{id:[0-9]+}"
  _route "error/404",                   "*page"


exports.$inject = [
  "$stateProvider"
  "$locationProvider"
  "$urlMatcherFactoryProvider"
  "$urlRouterProvider"
]
