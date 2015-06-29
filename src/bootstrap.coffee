name = "[bootstrap]"
console.log name, "initializing"

# Step 2: After fetching manifest (localStorage or XHR), load it
loadManifest = (manifest, fromLocalStorage, timeout=10000) ->
  console.log name, "manifest downloaded, parsing now"

  # Safety timeout. If BOOTSTRAP_OK is not defined,
  # it will delete the "localStorage" version and revert to factory settings.
  # Load Scripts
  loadScripts = ->
    console.log name, "loading scripts from", manifest.root
    scripts.forEach (src) ->
      if not src then return
      console.log name, "loading", src
      # Ensure the "src" has no "/" (it's in the root already)
      if src[0] is "/" then src = src.substr 1

      src = "#{manifest.root}#{src}"

      if src.substr(-3) is ".js" # Load javascript
        el = document.createElement "script"
        el.type = "text/javascript"
        el.src = "#{src}?#{now}"
        el.async = false
      else # Load CSS
        el = document.createElement "link"
        el.rel = "stylesheet"
        el.href = "#{src}?#{now}"
        el.type = "text/css"
      head.appendChild el


  if fromLocalStorage
    setTimeout (->
      if not window.BOOTSTRAP_OK
        console.warn "BOOTSTRAP_OK !== true; Resetting to original manifest.json..."
        # localStorage.removeItem "manifest"
        # location.reload()
    ), timeout

  if not manifest.load
    console.error "Manifest has nothing to load (manifest.load is empty).", manifest

  el = undefined
  head = document.getElementsByTagName("head")[0]
  scripts = manifest.load.concat()
  now = Date.now()

  #---------------------------------------------------
  # Step 3: Ensure the "root" exists and ends with a "/"
  manifest.root = manifest.root or "./"
  if manifest.root.length > 0 and manifest.root[manifest.root.length - 1] != "/"
    manifest.root += "/"

  # Step 4: Save manifest for next time
  if not fromLocalStorage
    localStorage.setItem "manifest", JSON.stringify manifest

  # Step 5: Load Scripts
  # If we're loading Cordova files, make sure Cordova is ready first!
  if typeof window.cordova != "undefined"
    document.addEventListener "deviceready", loadScripts, false
  else loadScripts()

  # Save to global scope
  window.Manifest = manifest


# Retrieved and slightly modified from: https://github.com/typicode/pegasus
# --------------------------------------------------------------------------
#
# a   url (naming it a, beacause it will be reused to store callbacks)
# xhr placeholder to avoid using var, not to be used
#------------------------------------------------------------------
window.pegasus = (a, xhr) ->
  xhr = new XMLHttpRequest
  # Open url
  xhr.open "GET", a
  # Reuse a to store callbacks
  a = []
  # onSuccess handler
  # onError   handler
  # cb        placeholder to avoid using var, should not be used
  xhr.onreadystatechange = xhr.then = (onSuccess, onError, cb) ->
    # Test if onSuccess is a function or a load event
    if onSuccess.call
      a = [
        onSuccess
        onError
      ]

    # Test if request is complete
    if xhr.readyState == 4

      # index will be:
      # 0 if status is between 0 and 399
      # 1 if status is over
      cb = a[0 | xhr.status / 400]

      # Safari doesn't support xhr.responseType = "json"
      # so the response is parsed
      if cb
        if xhr.status == 200 or xhr.status == 0
          try cb JSON.parse xhr.responseText
          catch e
            console.error e
            console.error name, "manifest.json is not valid JSON"
        else cb xhr

  # Send
  xhr.send()

  # Return request
  xhr


#---------------------------------------------------------------------
window.Manifest = {}

# Step 1: Load manifest from localStorage
downloadManifest = ->
  console.log name, "searching for manifest.json"
  manifest = JSON.parse localStorage.getItem "manifest"

  # grab manifest.json location from <script manifest="..."></script>
  s = document.querySelector "script[manifest]"

  # Not in localStorage? Fetch it!
  if not manifest
    url = s.getAttribute "manifest"
    console.log name, "downloading manifest using XHR"

    # get manifest.json, then loadManifest.
    pegasus(url).then loadManifest, (xhr) ->
      console.error "Could not download #{url}:#{xhr.status}"

  # Manifest was in localStorage. Load it immediatly.
  else
    console.log name, "retrieving manifest from localStorage"
    loadManifest manifest, true, s.getAttribute "timeout"
downloadManifest()
