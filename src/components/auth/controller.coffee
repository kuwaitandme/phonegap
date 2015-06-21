name = "[component:auth]"
scrollPosition = 0
body = (document.getElementsByTagName "body")[0]


exports = module.exports = ($scope, $element, $root, $timeout, $location, $log, $notifications, Users) ->
  $log.log name, "initializing"

  $scope.close = ->
    $element.removeClass "fade"
    $timeout (-> body.scrollTop = scrollPosition ), 200
    $timeout (-> $element.removeClass "show"), 500
    $root.bodyStyles.overflowY = ""


  $scope.open = ->
    $scope.tab = "main"
    $root.bodyStyles.overflowY = "hidden"
    scrollPosition = body.scrollTop
    $element.addClass "show"
    $timeout (-> $element.addClass "fade"), 100


  $scope.goto = (name) -> $scope.tab = name


  $scope.login = {}
  $scope.doLogin = ->
    Users.login $scope.login
    .then (response) ->
      if $location.path() in ["/", ""] then $location.path "/account"
      $location.search "_success", "login_success"
      $scope.close()
      $root.$broadcast "user:refresh"
    .catch (response) ->
      $notifications.error "Invalid login. Please check your credentials"
      $log.error name, response.data, response.status


  # Function to perform user registration
  $scope.signup = {}
  $scope.doSignup = ->
    Users.signup $scope.signup
    .then (response) ->
      $log.log name, "signup successful! waiting for activation page"
      $notifications.success "An activation email has been sent, #{response.data.full_name}! (Check your spam folder too)", 10000
      $root.$broadcast "user:refresh"
      $scope.close()
    .catch (response) ->
      $notifications.error "Signup failed. Please check your credentials or try again later"
      $log.error name, response.data, response.status


  $scope.$on "auth:show", -> $scope.open()
  $scope.$on "auth:show-signup", (event, data) ->
    $scope.open()
    $scope.tab = "signup"
    $scope.signup = angular.extend $scope.signup, data


exports.$inject = [
  "$scope"
  "$element"
  "$rootScope"
  "$timeout"
  "$location"
  "$log"
  "$notifications"

  "models.users"
]