window.CordovaPromiseFS = require "./updater/CordovaPromiseFS"
window.CordovaAppLoader = require "./updater/CordovaAppLoader"


# Check for Cordova
isCordova = typeof cordova != "undefined"

# Check > Download > Update
check = ->
  loader.check()
  .then -> loader.download()
  .then -> loader.update()
  .catch (err) -> console.error "Auto-update error:", err


# Get serverRoot from script tag.
script = document.querySelector "script[server]"
if script then serverRoot = script.getAttribute "server"
if not serverRoot
  throw new Error "Add a 'server' attribute to the bootstrap.js script!"

# Initialize filesystem and loader
fs = new CordovaPromiseFS
  persistent: isCordova
  Promise: Promise

loader = new CordovaAppLoader
  fs: fs
  localRoot: "./"
  serverRoot: serverRoot
  mode: "mirror"
  cacheBuster: true

# Couple events:
# 1. On launch
check()

# 2. Cordova: On resume
fs.deviceready.then -> document.addEventListener "resume", check
document.addEventListener "webkitvisibilitychange", onVisibilityChange, false

# 3. Chrome: On page becomes visible again
onVisibilityChange = -> if not document.webkitHidden then check()