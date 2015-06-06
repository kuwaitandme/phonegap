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
        categories: ["models.categories", (category) -> category.download()]
        user: ["models.users", (user) -> user.download()]
        location: ["models.locations", (location) -> location.download()]

  _route "index",              ""
  _route "account",            "/account"
  _route "account/manage",     "/account/manage"
  _route "auth",               "/auth"
  _route "auth/logout",        "/auth/logout"
  _route "guest/post",         "/guest/post"
  _route "classified/finish",  "/classified/finish/{id:[0-9]+}"
  _route "classified/edit",    "/classified/edit/{id:[0-9]+}"
  _route "classified/post",    "/classified/post"
  _route "classified/search",  "/classified"
  _route "classified/search",  "/classified/{parent:[^/]+}"
  _route "classified/search",  "/classified/{parent:[^/]+}/{child:[^/]+}"
  _route "classified/single",  "/{slug:[^/]+-[0-9]+}"
  _route "error/404",          "*page"


exports.$inject = [
  "$stateProvider"
  "$locationProvider"
  "$urlMatcherFactoryProvider"
  "$urlRouterProvider"
]