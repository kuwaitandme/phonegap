console.log "[app] initializing do"
app = angular.module "App", [
  # "ngCookies"
  # "ngSanitize"
  "ngTouch"
  "ui.router"
  "cfp.hotkeys"
  # "swipe"
  # "btford.socket-io"
]


(require "./components")    app
(require "./config")        app
(require "./directives")    app
(require "./filters")       app
(require "./libraries")     app
(require "./models")        app
(require "./providers")     app
(require "./run")           app
(require "./services")      app
(require "./values")        app
(require "./views")         app


# Helper function to boot the angular App.
boot = ->
  console.log "[app] bootstraping angular"
  html = (document.getElementsByTagName "html")[0]
  body = angular.element (document.getElementsByTagName "body")[0]
  body.removeClass "initializing"
  angular.bootstrap html, ["App"]

window.BOOTSTRAP_OK = true

window.publicData =
  url: "https://kuwaitandme.com"
  staticUrl: "https://static.kuwaitandme.com"
  google: {}

if cordova? then document.addEventListener "deviceready", -> boot()
else boot()
