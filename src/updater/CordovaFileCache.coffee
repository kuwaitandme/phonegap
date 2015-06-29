murmurhash3 = require "./murmurhash3"

Promise = null
isCordova = cordova?
name = "[cordova:file-cache]"


###*
# Cordova File Cache
###
module.exports = class CordovaFileCache

  # set internal variables
  _downloading: []

  # download promises
  _added: []

  # added files
  _cached: {}

  constructor: (options) ->
    console.log name, "initializing"
    console.debug name, options

    @_fs = options.fs
    if not @_fs
      throw new Error "Missing required option 'fs'. Add an instance of
        cordova-promise-fs."

    # Use Promises from fs.
    Promise = @_fs.Promise

    # "mirror" mirrors files structure from "serverRoot" to "localRoot"
    # "hash" creates a 1-deep filestructure, where the filenames are hashed
    # server urls (with extension)
    @_mirrorMode = options.mode != "hash"
    @_retry = options.retry or [
      500
      1500
      8000
    ]
    @_cacheBuster = !!options.cacheBuster

    # normalize path
    @localRoot = @_fs.normalize options.localRoot or "data"
    @serverRoot = @_fs.normalize options.serverRoot or ""

    # cached files
    # list existing cache contents
    @ready = @_fs.ensure @localRoot
    .then (entry) =>
      if isCordova then @localInternalURL = entry.toInternalURL()
      else @localInternalURL = entry.toURL()
      @localUrl = entry.toURL()
      @list()


  ###*
  # Helper to cache all 'internalURL' and 'URL' for quick synchronous access
  # to the cached files.
  ###
  list: -> new Promise (resolve, reject) =>
    @_fs.list @localRoot, "rfe"
    .then (entries) =>
      @_cached = {}
      entries = entries.map (e) =>
        fullPath = @_fs.normalize e.fullPath
        @_cached[fullPath] =
          toInternalURL: if isCordova then e.toInternalURL() else e.toURL()
          toURL: e.toURL()
        fullPath
      resolve entries
    , -> resolve []


  add: (urls) ->
    if not urls then urls = []
    if typeof urls == "string" then urls = [urls]

    urls.forEach (url) =>
      url = @toServerURL(url)
      if @_added.indexOf(url) == -1 then @_added.push url

    @isDirty()



  remove: (urls=[], returnPromises) ->
    promises = []
    if typeof urls == "string" then urls = [urls]

    urls.forEach (url) =>
      index = @_added.indexOf @toServerURL url
      if index >= 0 then @_added.splice index, 1
      path = @toPath url
      promises.push @_fs.remove path
      delete @_cached[path]

    if returnPromises then Promise.all promises else @isDirty()


  getDownloadQueue: -> @_added.filter (u) => not @isCached u


  getAdded: -> @_added


  isDirty: -> @getDownloadQueue().length > 0


  download: (onprogress) ->
    fs = @_fs
    @abort()
    new Promise (resolve, reject) =>
      # make sure cache directory exists and that
      # we have retrieved the latest cache contents
      # to avoid downloading files we already have!
      fs.ensure @localRoot
      .then => @list()
      .then =>
        # no dowloads needed, resolve
        if !@isDirty() then return resolve self

        # keep track of number of downloads!
        queue = @getDownloadQueue()
        started = []
        index = @_downloading.length
        done = @_downloading.length
        total = @_downloading.length + queue.length

        # download every file in the queue (which is the diff from _added with
        # _cached)
        queue.forEach (url) =>
          console.debug name, "downloading", url
          path = @toPath url
          # augment progress event with index/total stats
          onSingleDownloadProgress = undefined
          if typeof onprogress == "function"
            onSingleDownloadProgress = (ev) ->
              ev.queueIndex = index
              ev.queueSize = total
              ev.url = url
              ev.path = path
              ev.percentage = index / total
              if ev.loaded > 0 and ev.total > 0 and index != total
                ev.percentage += ev.loaded / ev.total / total
              if started.indexOf(url) < 0
                started.push url
                index++
              onprogress ev

          # callback
          onDone = =>
            done++
            # when we're done
            if done is total
              # reset downloads
              @_downloading = []
              # check if we got everything
              @list().then =>
                # final progress event!
                if onSingleDownloadProgress
                  onSingleDownloadProgress new ProgressEvent
                # Yes, we're not dirty anymore!
                if not @isDirty() then resolve this
                  # Aye, some files got left behind!
                else reject @getDownloadQueue()
              , reject


          downloadUrl = url
          if @_cacheBuster then downloadUrl += "?#{Date.now()}"

          download = fs.download downloadUrl, path, { retry: self._retry },
            onSingleDownloadProgress

          download.then onDone, onDone
          @_downloading.push download
      , reject


  abort: ->
    @_downloading.forEach (download) -> download.abort()
    @_downloading = []


  isCached: (url) ->
    url = @toPath url
    !!@_cached[url]


  clear: ->
    @_cached = {}
    @_fs.removeDir @localRoot
    .then => @_fs.ensure @localRoot


  ###
  # Helpers to output to various formats
  ###
  toInternalURL: (url) ->
    path = @toPath url
    if @_cached[path] then return @_cached[path].toInternalURL
    url


  get: (url) ->
    path = @toPath url
    if @_cached[path] then return @_cached[path].toInternalURL
    @toServerURL url


  toDataURL: (url) -> @_fs.toDataURL @toPath url


  toURL: (url) ->
    path = @toPath url
    if @_cached[path] then @_cached[path].toURL else url


  toServerURL: (path) ->
    path = @_fs.normalize path
    if path.indexOf("://") < 0 then "#{@serverRoot}#{path}" else path


  ###*
  # Helper to transform remote URL to a local path (for cordova-promise-fs)
  ###
  toPath: (url="") ->
    if @_mirrorMode
      query = url.indexOf "?"
      if query > -1 then url = url.substr 0, query
      url = @_fs.normalize url
      len = @serverRoot.length
      if url.substr(0, len) != @serverRoot then @localRoot + url
      else @localRoot + url.substr len
    else "#{@localRoot}#{hash url}#{url.substr url.lastIndexOf "."}"


CordovaFileCache.hash = murmurhash3