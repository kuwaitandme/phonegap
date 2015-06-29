window.CordovaPromiseFS = PromiseFS = require "./updater/CordovaPromiseFS"
window.CordovaAppLoader = AppLoader = require "./updater/CordovaAppLoader"

name = "[autoupdate]"

# Check for Cordova
isCordova = cordova?

# Check > Download > Update
check = ->
  console.log name, "checking"
  loader.check()
  .then ->
    console.log name, "downloading"
    loader.download()
  .then ->
    console.log name, "updating"
    loader.update()
  .catch (err) -> console.error name, "Auto-update error:", err


# Get serverRoot from script tag.
script = document.querySelector "script[server]"
if script then serverRoot = script.getAttribute "server"
if not serverRoot
  throw new Error "Add a 'server' attribute to the bootstrap.js script!"

# Initialize filesystem and loader
fs = new PromiseFS
  persistent: false
  Promise: Promise

loader = new AppLoader
  fs: fs
  localRoot: "./"
  serverRoot: serverRoot
  mode: "mirror"
  cacheBuster: true

window.a = fs

# Couple events:
# 1. On launch
check()

# 2. Cordova: On resume
fs.deviceready.then -> document.addEventListener "resume", check
document.addEventListener "webkitvisibilitychange", onVisibilityChange, false

# 3. Chrome: On page becomes visible again
onVisibilityChange = -> if not document.webkitHidden then check()