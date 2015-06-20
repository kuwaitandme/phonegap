exports = module.exports = ($log, $http) ->
  body = document.body
  name = "[run:http]"
  $log.log @name, "initializing"

  $http.defaults.headers.common['x-phonegap'] =
    "09bd717ded37719c15c190990d91dd59"


exports.$inject = [
  "$log"
  "$http"
]