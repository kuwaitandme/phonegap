module.exports = Backbone.View.extend
  name: '[view:classified-post:images]'
  events: 'click .dz-preview .delete div': 'removeFile'

  initialize: (options) ->
    if options.model     then     @model = options.model
    if options.$el       then       @$el = options.$el
    if options.resources then @resources = options.resources

    @$filePreview = @$ '#image-upload-preview'
    @filesToDelete = []

    @on "close", @close

    @setDOM()

    # window.imagePicker.getPictures (results) ->
    #     for result in results.length
    #       console.log "Image URI: #{result}"
    #   , (error) -> console.log "Error: #{error}"

    onPhotoURISuccess = (result) =>
      blob = @dataURLtoBlob "data:image/jpeg;base64,#{result}"
      blobs = [blob]
      @model.set 'blobs', blobs

    getPhoto = (source) ->
      navigator.camera.getPicture onPhotoURISuccess, onPhotoURISuccess,
        quality: 50
        sourceType: source
    getPhoto Camera.PictureSourceType.PHOTOLIBRARY

  validate: ->
    @setModel()
    true

  dataURItoBlob: (dataURI) ->
    # convert base64/URLEncoded data component to raw binary data held in a string
    if (dataURI.split ',')[0].indexOf('base64') >= 0
        byteString = atob dataURI.split(',')[1]
    else
        byteString = unescape dataURI.split(',')[1]

    window.b = byteString
    # separate out the mime component
    mimeString = (dataURI.split ',')[0].split(':')[1].split(';')[0]

    # write the bytes of the string to a typed array
    ia = new Uint8Array byteString.length
    for i in [0...byteString.length]
        ia[i] = byteString.charCodeAt i

    # create the final blob which can be used in file uploads
    new Blob [ia], type: mimeString

  dataURLtoBlob: (dataURL) ->
    BASE64_MARKER = ';base64,'

    if dataURL.indexOf(BASE64_MARKER) == -1

      parts = dataURL.split ','
      contentType = parts[0].split(':')[1]
      window.b = parts
      raw = decodeURIComponent parts[1]
      return new Blob [raw], type: contentType

    parts = dataURL.split BASE64_MARKER
    contentType = parts[0].split(':')[1]
    raw = window.atob parts[1]
    rawLength = raw.length

    uInt8Array = new Uint8Array rawLength
    i=0
    while i < rawLength
      uInt8Array[i] = raw.charCodeAt i
      ++i
    new Blob [uInt8Array], type: contentType


  # Handler function to remove the file from the Uploads queue
  removeFile: (event) ->
    # Find the index of the file
    $el = $(event.currentTarget)
    $li = $el.parent().parent()
    src = ($li.find 'img').attr 'alt'
    index = $li.index()

    if $li.data 'uploaded'
      # Set this in our queue of files that have to removed from the
      # server
      @filesToDelete.push src
    else
      # Remove it from the file Queue
      for file in @dropzone.files
        if file.name is src then file.status = 'delete'


    # Remove the thumbnail from the DOM
    $li.remove()


  # Initializes the drop-zone
  initDropzone: ->
    Dropzone.autoDiscover = false

    # Create the dropzone
    $el = ((@$ '#image-upload').eq 0).dropzone url: '/'
    @dropzone = $el[0].dropzone
    @dropzone.previewsContainer = @$filePreview[0]

    # Setup each of the custom options for the drop-zone
    options = @dropzone.options
    options.autoProcessQueue = false
    options.paramName = 'files'
    options.uploadMultiple = true
    options.previewTemplate = '
      <li class="dz-preview">\
        <img data-dz-thumbnail />\
        <div class="font-awesome delete">\
          <div>&#xf00d;</div>\
        </div>
      </li>'


  addImage: (img) ->
    html = "<li class='dz-preview dz-image-preview' data-uploaded='true'>
      <img data-dz-thumbnail='' alt='#{img}' src='/uploads/thumb/#{img}'>
      <div class='font-awesome delete'><div>&#xf00d;</div></div>
    </li>"
    @$filePreview.append html


  setModel: ->
    # Start grabbing the files from the drop-zone
    # files = @dropzone.getQueuedFiles()

    # # Append each file into the model
    # @model.attributes.files = []
    # for file in files
    #   @model.attributes.files.push file

    # @model.set 'filesToDelete', @filesToDelete


  setDOM: ->
    images = @model.get 'images'
    for image in images then @addImage image


  close: ->
    @remove()
    @unbind()
    @stopListening()