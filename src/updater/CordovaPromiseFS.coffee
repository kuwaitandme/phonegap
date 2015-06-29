transferQueue = []
inprogress = 0
Promise = null
# currently active filetransfers

name = "[cordova:fileSystem]"

###*
# Factory function: Create a single instance (based on single FileSystem)
###

###*
# Static Private functions
###

### createDir, recursively ###
__createDir = (rootDirEntry, folders, success, error) ->
  rootDirEntry.getDirectory folders[0], { create: true }, (dirEntry) ->
    # Recursively add the new subfolder (if we still have another to create).
    if folders.length > 1
      __createDir dirEntry, folders.slice(1), success, error
    else success dirEntry
  , error


dirname = (str="") ->
  str = str.substr 0, str.lastIndexOf("/") + 1
  if str[0] == "/" then str = str.substr 1
  str


filename = (str="") -> str.substr str.lastIndexOf "/" + 1


normalize = (str="") ->
  if str[0] == "/" then str = str.substr(1)
  if ! !str and str.indexOf('.') < 0 and str[str.length - 1] != "/"
    str += "/"
  if str == "./" then str = ''
  str


CordovaPromiseFS = module.exports = (options) ->

  ### Promise implementation ###
  Promise = options.Promise or window.Promise

  ### Promise resolve helper ###
  ResolvedPromise = (value) -> new Promise (resolve) -> resolve value


  ### ensure directory exists ###
  ensure = (folders) ->
    new Promise (resolve, reject) ->
      fs.then (fs) ->
        if not folders then resolve fs.root
        else
          folders = folders.split('/').filter (folder) ->
            folder and folder.length > 0 and folder != '.' and folder != '..'

          __createDir fs.root, folders, resolve, reject
      , reject


  ### get file file ###
  file = (path, options={}) ->
    new Promise (resolve, reject) ->
      if typeof path == "object" then return resolve path
      path = normalize path
      fs.then ((fs) -> fs.root.getFile path, options, resolve, reject), reject


  ### get directory entry ###
  dir = (path, options={}) ->
    path = normalize path
    new Promise (resolve, reject) ->
      fs.then ((fs) ->
        if not path or path == "/" then resolve fs.root
        else fs.root.getDirectory path, options, resolve, reject
      ), reject


  ### list contents of a directory ###
  list = (path, mode="") ->
    recursive = mode.indexOf('r') > -1
    getAsEntries = mode.indexOf('e') > -1
    onlyFiles = mode.indexOf('f') > -1
    onlyDirs = mode.indexOf('d') > -1
    if onlyFiles and onlyDirs then onlyFiles = onlyDirs = false

    new Promise (resolve, reject) ->
      dir path
      .then ((dirEntry) ->
        dirReader = dirEntry.createReader()
        dirReader.readEntries ((entries) ->
          promises = [ ResolvedPromise entries ]

          if recursive
            entries.filter (entry) -> entry.isDirectory
            .forEach (entry) -> promises.push list entry.fullPath, "re"

          Promise.all promises
          .then (values) ->
            entries = []
            entries = entries.concat.apply entries, values
            if onlyFiles
              entries = entries.filter (entry) -> entry.isFile

            if onlyDirs
              entries = entries.filter (entry) -> entry.isDirectory

            if not getAsEntries
              entries = entries.map (entry) -> entry.fullPath

            resolve entries
          .then (e) -> window.b = e
          .catch (e) -> reject e

        ), reject
      ), reject


  ###
    Does file exist? If so, resolve with fileEntry, if not, resolve with
    false.
  ###
  exists = (path) ->
    new Promise (resolve, reject) ->
      file path
      .then ((fileEntry) -> resolve fileEntry), (err) ->
        if err.code is 1 then resolve false
        else reject err


  create = (path) -> ensure(dirname(path)).then -> file path, create: true


  ### convert path to URL to be used in JS/CSS/HTML ###
  toURL = (path) -> file(path).then (fileEntry) -> fileEntry.toURL()


  ### return contents of a file ###
  read = (path, method="readAsText") ->
    file path
    .then (fileEntry) ->
      new Promise (resolve, reject) ->
        fileEntry.file (file) ->
          reader = new FileReader
          reader.onloadend = -> resolve @result
          reader[method] file
        , reject



  ### convert path to base64 date URI ###
  toDataURL = (path) -> read path, "readAsDataURL"



  readJSON = (path) -> read(path).then JSON.parse


  ### write contents to a file ###
  write = (path, blob, mimeType) ->
    console.debug name, "writing to", path
    ensure dirname path
    .then -> file path, create: true
    .then (fileEntry) ->
      new Promise (resolve, reject) ->
        fileEntry.createWriter (writer) ->
          writer.onwriteend = resolve
          writer.onerror = reject
          if typeof blob == "string"
            blob = new Blob [ blob ], type: mimeType or "text/plain"
          else if blob instanceof Blob != true
            blob = new Blob [ JSON.stringify(blob, null, 4) ],
              type: mimeType or "application/json"
          writer.write blob
        , reject


  ### move a file ###
  move = (src, dest) ->
    ensure dirname dest
    .then (dir) -> file src
    .then (fileEntry) ->
      new Promise (resolve, reject) ->
        fileEntry.moveTo dir, filename(dest), resolve, reject


  ### copy a file ###
  copy = (src, dest) ->
    ensure dirname dest
    .then (dir) -> file src
    .then (fileEntry) ->
      new Promise (resolve, reject) ->
        fileEntry.copyTo dir, filename(dest), resolve, reject


  ### delete a file ###
  remove = (path, mustExist) ->
    method = if mustExist then file else exists
    new Promise (resolve, reject) ->
      method path
      .then (fileEntry) ->
        if fileEntry != false then fileEntry.remove resolve, reject
        else resolve 1
      , reject
    .then (val) -> if val == 1 then false else true


  ### delete a directory ###
  removeDir = (path) ->
    dir path
    .then (dirEntry) ->
      new Promise (resolve, fail) -> dirEntry.removeRecursively resolve, fail


  # Whenever we want to start a transfer, we call popTransferQueue
  popTransferQueue = ->
    # while we are not at max concurrency
    while transferQueue.length > 0 and inprogress < options.concurrency
      # increment activity counter
      inprogress++
      # fetch filetranfer, method-type (isDownload) and arguments
      args = transferQueue.pop()
      ft = args.shift()
      isDownload = args.shift()
      serverUrl = args.shift()
      localPath = args.shift()
      win = args.shift()
      fail = args.shift()
      trustAllHosts = args.shift()
      transferOptions = args.shift()
      if ft._aborted then inprogress--
      else if isDownload
        ft.download.call ft, serverUrl, localPath, win, fail, trustAllHosts,
          transferOptions
        if ft.onprogress
          ft.onprogress new ProgressEvent
      else ft.upload.call ft, localPath, serverUrl, win, fail, transferOptions,
          trustAllHosts
    # if we are at max concurrency, popTransferQueue() will be called whenever
    # the transfer is ready and there is space avaialable.


  # Promise callback to check if there are any more queued transfers
  nextTransfer = (result) ->
    inprogress--
    # decrement counter to free up one space to start transfers again!
    popTransferQueue()
    # check if there are any queued transfers
    result


  filetransfer = (isDownload, serverUrl, localPath, transferOptions, onprogress) ->
    if typeof transferOptions == "function"
      onprogress = transferOptions
      transferOptions = {}
    if isCordova and localPath.indexOf('://') < 0
      localPath = toInternalURLSync(localPath)
    transferOptions = transferOptions or {}
    if !transferOptions.retry or !transferOptions.retry.length
      transferOptions.retry = options.retry
    transferOptions.retry = transferOptions.retry.concat()
    if !transferOptions.file and !isDownload
      transferOptions.fileName = filename localPath
    ft = new FileTransfer
    onprogress = onprogress or transferOptions.onprogress
    if typeof onprogress == "function" then ft.onprogress = onprogress
    promise = new Promise (resolve, reject) ->
      attempt = (err) ->
        if transferOptions.retry.length == 0 then reject err
        else
          transferQueue.unshift [
            ft
            isDownload
            serverUrl
            localPath
            resolve
            attempt
            transferOptions.trustAllHosts or false
            transferOptions
          ]
          timeout = transferOptions.retry.shift()
          if timeout > 0 then setTimeout nextTransfer, timeout
          else nextTransfer()

      transferOptions.retry.unshift 0
      inprogress++
      attempt()


    promise.then nextTransfer, nextTransfer
    promise.progress = (onprogress) ->
      ft.onprogress = onprogress
      promise

    promise.abort = ->
      ft._aborted = true
      ft.abort()
      promise

    promise


  download = (url, dest, options, onprogress) ->
    console.debug name, "downloading", url
    filetransfer true, url, dest, options, onprogress


  upload = (source, dest, options, onprogress) ->
    console.log name, "uploading", source
    filetransfer false, dest, source, options, onprogress

  if not Promise?
    throw new Error "No Promise library given in options.Promise"


  ### default options ###
  @options = options = options or {}
  options.persistent ?= itrue
  options.storageSize ?= 20 * 1024 * 1024
  options.concurrency ?= 3
  options.retry ?= []




  ### Cordova deviceready promise ###
  deviceready = undefined
  isCordova = cordova?
  if isCordova
    deviceready = new Promise (resolve, reject) ->
      document.addEventListener "deviceready", resolve, false
      setTimeout (->
        reject new Error "deviceready has not fired after 5 seconds."
      ), 5100

  else
    ### FileTransfer implementation for Chrome ###
    deviceready = ResolvedPromise true
    if webkitRequestFileSystem?
      window.requestFileSystem = webkitRequestFileSystem

      window.FileTransfer = ->
      FileTransfer::download = (url, file, win, fail) ->
        xhr = new XMLHttpRequest
        xhr.open "GET", url
        xhr.responseType = "blob"

        xhr.onreadystatechange = (onSuccess, onError, cb) ->
          if xhr.readyState is 4
            if xhr.status is 200 then write(file, xhr.response).then win, fail
            else fail xhr.status

        xhr.send()
        xhr

      window.ProgressEvent = ->
      window.FileEntry = ->

    else window.requestFileSystem = (x, y, z, fail) ->
      fail new Error "requestFileSystem not supported!"


  ### the filesystem! ###
  fs = new Promise (resolve, reject) ->
    deviceready.then ->
      type = if options.persistent then 1 else 0
      if typeof options.fileSystem == 'number'
        type = options.fileSystem
      # Chrome only supports persistent and temp storage, not the exotic onces from Cordova
      if not isCordova and type > 1
        console.warn "Chrome does not support fileSystem '#{type}'. Falling
          back on '0' (temporary)."
        type = 0
      window.requestFileSystem type, options.storageSize, resolve, reject
      setTimeout ->
        reject new Error "Could not retrieve FileSystem after 5 seconds."
      , 5100
    , reject


  ### debug ###
  fs.then ((fs) -> window.__fs = fs)
  ,  (err) -> console.error "Could not get Cordova FileSystem:", err


  ### convert path to URL to be used in JS/CSS/HTML ###
  toInternalURL = undefined
  toInternalURLSync = undefined


  ### synchronous helper to get internal URL. ###
  toInternalURLSync = (path) ->
    path = normalize path
    type = if options.persistent then "persistent" else "temporary"
    if isCordova
      if path.indexOf("://") < 0 then "cdvfile://localhost/#{type}/#{path}"
      else path
    else "filesystem:#{location.origin}/#{type}/#{path}"


  toInternalURL = (path) ->
    file path
    .then (fileEntry) ->
      console.debug fileEntry.toURL()
      fileEntry.toURL()
      # if isCordova then fileEntry.toInternalURL()
      # else fileEntry.toURL()


  {
    fs: fs
    Promise: Promise

    copy: copy
    create: create
    deviceready: deviceready
    dir: dir
    dirname: dirname
    download: download
    ensure: ensure
    exists: exists
    file: file
    filename: filename
    isCordova: isCordova
    list: list
    move: move
    normalize: normalize
    options: options
    read: read
    readJSON: readJSON
    remove: remove
    removeDir: removeDir
    toDataURL: toDataURL
    toInternalURL: toInternalURL
    toInternalURLSync: toInternalURLSync
    toURL: toURL
    upload: upload
    write: write
  }