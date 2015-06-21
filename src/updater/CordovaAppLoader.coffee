CordovaFileCache = require "./CordovaFileCache"
CordovaPromiseFS = require "./CordovaPromiseFS"

BUNDLE_ROOT = location.href.replace location.hash, ""
BUNDLE_ROOT = BUNDLE_ROOT.substr 0, BUNDLE_ROOT.lastIndexOf("/") + 1
if /ip(hone|ad|od)/i.test navigator.userAgent
  BUNDLE_ROOT = location.pathname.substr location.pathname.indexOf "/www/"
  BUNDLE_ROOT = BUNDLE_ROOT.substr 0, BUNDLE_ROOT.lastIndexOf "/" + 1
  BUNDLE_ROOT = "cdvfile://localhost/bundle#{BUNDLE_ROOT}"

name = "[cordova:app-loader]"


hash = (files) ->
  keys = Object.keys files
  keys.sort()
  str = ""
  keys.forEach (key) ->
    if files[key] and files[key].version then str += "@#{files[key].version}"
  "#{CordovaFileCache.hash str}"


module.exports = CordovaAppLoader = class
  constructor: (options) ->
    console.log name, "initializing"
    console.debug name, options
    if not options
      throw new Error "CordovaAppLoader has no options!"
    if not options.fs
      throw new Error "CordovaAppLoader has no 'fs' option
        (cordova-promise-fs)"
    if not options.serverRoot
      throw new Error "CordovaAppLoader has no 'serverRoot' option."
    if not window.pegasus or not window.Manifest
      throw new Error "CordovaAppLoader bootstrap.js is missing."

    @allowServerRootFromManifest = options.allowServerRootFromManifest == true
    Promise = options.fs.Promise

    # initialize variables
    @manifest = window.Manifest
    @newManifest = null
    @bundledManifest = null
    @_lastUpdateFiles = localStorage.getItem "last_update_files"

    # normalize serverRoot and set remote manifest url
    options.serverRoot ?= ""
    if !!options.serverRoot and
    options.serverRoot[options.serverRoot.length - 1] != "/"
      options.serverRoot += "/"

    @newManifestUrl = options.manifestUrl or options.serverRoot +
      (options.manifest or "manifest.json")

    # initialize a file cache
    if options.mode then options.mode = "mirror"

    @cache = new CordovaFileCache options

    # private stuff
    @corruptNewManifest = false
    @_toBeCopied = []
    @_toBeDeleted = []
    @_toBeDownloaded = []
    @_updateReady = false
    @_checkTimeout = options.checkTimeout or 10000


  _createFilemap: (files) ->
    result = {}
    normalize = @cache._fs.normalize
    Object.keys files
    .forEach (key) ->
      files[key].filename = normalize files[key].filename
      result[files[key].filename] = files[key]
    result

  copyFromBundle: (file) ->
    url = BUNDLE_ROOT + file
    @cache._fs.download url, @cache.localRoot + file

  getBundledManifest: ->
    script = document.querySelector "script[manifest]"
    if bundledManifestUrl = script.getAttribute "manifest"
    else bundledManifestUrl = "manifest.json"

    # bundledManifestUrl = (if bootstrapScript then bootstrapScript.getAttribute
    # ('manifest') else null) or 'manifest.json'
    new Promise (resolve, reject) =>
      if @bundledManifest then resolve @bundledManifest
      else
        pegasus bundledManifestUrl
        .then (bundledManifest) =>
          @bundledManifest = bundledManifest
          resolve bundledManifest
        , reject
        setTimeout (-> reject new Error "bundled manifest timeout")
        , @_checkTimeout


  ###
    Use this function to check the server and download a new manifest file.
  ###
  check: (newManifest) ->
    self = this
    manifest = @manifest

    if typeof newManifest == 'string'
      @newManifestUrl = newManifest
      newManifest = undefined

    gotNewManifest = new Promise (resolve, reject) =>
      if typeof newManifest == "object" then resolve newManifest
      else
        pegasus @newManifestUrl
        .then resolve, reject
        setTimeout (-> reject new Error "new manifest timeout")
        , @_checkTimeout

    new Promise (resolve, reject) =>
      Promise.all [
        gotNewManifest
        @getBundledManifest()
        @cache.list()
      ]
      .then (values) =>
        newManifest = values[0]
        bundledManifest = values[1]
        newFiles = hash newManifest.files
        # Prevent end-less update loop, check if new manifest
        # has been downloaded before (but has failed)
        # Check if the newFiles match the previous files (last_update_files)
        if newFiles == @_lastUpdateFiles
          # YES! So we're doing the same update again!
          # Check if our current Manifest has indeed the "last_update_files"
          currentFiles = hash Manifest.files
          if @_lastUpdateFiles != currentFiles
            # No! So we've updated, yet they don't appear in our manifest.
            # This means..
            console.warn "New manifest available, but an earlier update attempt
              failed. Will not download."
            @corruptNewManifest = true
            resolve null
          # Yes, we've updated and we've succeeded.
          return resolve false

        # Check if new manifest is valid
        if not newManifest.files
          return reject "Downloaded Manifest has no 'files' attribute."

        # We're good to go check! Get all the files we need
        cachedFiles = values[2]

        # files in cache
        oldFiles = @_createFilemap manifest.files

        # files in current manifest
        newFiles = @_createFilemap newManifest.files

        # files in new manifest
        bundledFiles = @_createFilemap bundledManifest.files

        # files in app bundle
        # Create COPY and DOWNLOAD lists
        @_toBeDownloaded = []
        @_toBeCopied = []
        @_toBeDeleted = []
        isCordova = @cache._fs.isCordova
        Object.keys newFiles
        .filter (file) =>
          # if new file, or...
          not oldFiles[file] or oldFiles[file].version !=
          newFiles[file].version or !@cache.isCached file
        .forEach (file) =>
          # bundled version matches new version, so we can copy!
          if isCordova and bundledFiles[file] and
          bundledFiles[file].version == newFiles[file].version
            @_toBeCopied.push file
            # othwerwise, we must download
          else @_toBeDownloaded.push file

        # Delete files
        @_toBeDeleted = cachedFiles.map (file) =>
          file.substr @cache.localRoot.length
        .filter (file) =>
          # Everything that is not in new manifest, or....
          !newFiles[file] or @_toBeDownloaded.indexOf(file) >= 0 or
          @_toBeCopied.indexOf(file) >= 0

        changes = @_toBeDeleted.length + @_toBeDownloaded.length
        # Note: if we only need to copy files, we can keep serving from bundle!
        # So no update is needed!
        if changes > 0
          # Save the new Manifest
          @newManifest = newManifest
          @newManifest.root = @cache.localInternalURL
          resolve true
        else resolve false
      , reject


  canDownload: -> !!@newManifest and !@_updateReady


  canUpdate: -> @_updateReady


  download: (onprogress) ->
    if !@canDownload() then return new Promise (resolve) -> resolve null

    # we will delete files, which will invalidate the current manifest...
    localStorage.removeItem "manifest"

    # only attempt this once - set 'last_update_files'
    localStorage.setItem "last_update_files", hash @newManifest.files
    @manifest.files = Manifest.files = {}

    @cache.remove @_toBeDeleted, true
    .then =>
      Promise.all @_toBeCopied.map (file) =>
        @cache._fs.download BUNDLE_ROOT + file, @cache.localRoot + file

    .then =>
      if @allowServerRootFromManifest and @newManifest.serverRoot
        @cache.serverRoot = @newManifest.serverRoot
      @cache.add @_toBeDownloaded
      @cache.download onprogress

    .then =>
      @_toBeDeleted = []
      @_toBeDownloaded = []
      @_updateReady = true
      @newManifest
    , (files) ->
      # on download error, remove files...
      if !!files and files.length then self.cache.remove files
      files


  update: (reload) ->
    if @_updateReady
      # update manifest
      localStorage.setItem "manifest", JSON.stringify @newManifest
      if reload != false then location.reload()
      return true
    false


  clear: ->
    localStorage.removeItem "last_update_files"
    localStorage.removeItem "manifest"
    @cache.clear()


  reset: -> @clear().then (-> location.reload()), -> location.reload()