module.exports = Backbone.View.extend
  name: '[view:classified-post:images]'
  template: template['classified/post/images']

  events:
    'click .dz-preview .delete div': 'removeFile'
    'click #camera' : 'cameraHandle'
    'click #gallery' : 'galleryHandle'

  start: (options) ->
    @$filePreview = @$ '#image-upload-preview'
    @filesToDelete = []
    @files = []

    @setDOM()

  b64toBlob: (b64Data, contentType='', sliceSize=512) ->
    byteCharacters = atob b64Data
    byteArrays = []
    offset = 0

    while offset < byteCharacters.length
      slice = byteCharacters.slice offset, offset + sliceSize
      byteNumbers = new Array slice.length
      i = 0
      while i < slice.length
        byteNumbers[i] = slice.charCodeAt i
        i++
      byteArray = new Uint8Array byteNumbers
      byteArrays.push byteArray
      offset += sliceSize
    new Blob byteArrays, type: contentType


  onPhotoURISuccess: (imageURI) ->
    the_file = @b64toBlob imageURI, 'image/jpeg'
    @files.push the_file
    @addImage imageURI

  cameraHandle: (event) ->
    event.preventDefault()
    console.log @name, 'Capturing photo from camera'

    onFail = (message) -> alert 'Failed because: ' + message
    onSuccess = (URI) => @onPhotoURISuccess URI
    navigator.camera.getPicture onSuccess, onFail,
      quality: 100
      destinationType: navigator.camera.DestinationType.DATA_URL
      sourceType: navigator.camera.PictureSourceType.CAMERA


  galleryHandle: (event) ->
    event.preventDefault()
    console.log @name, 'Capturing photo from gallery'

    onFail = (message) -> alert 'Failed because: ' + message
    onSuccess = (URI) => @onPhotoURISuccess URI
    navigator.camera.getPicture onSuccess, onFail,
      quality: 100
      destinationType: navigator.camera.DestinationType.DATA_URL
      sourceType: navigator.camera.PictureSourceType.SAVEDPHOTOALBUM


  # Handler function to remove the file from the Uploads queue
  removeFile: (event) ->
    # Find the index of the file
    $el = $(event.currentTarget)
    $li = $el.parent().parent()
    src = ($li.find 'img').attr 'alt'
    index = $li.index()

    if $li.data 'uploaded'
      # Set this in our queue of files that have to removed from the server
      @filesToDelete.push src
    else
      # Remove it from the file Queue
      for file in @dropzone.files
        if file.name is src then file.status = 'delete'


    # Remove the thumbnail from the DOM
    $li.remove()


  addImage: (URI) ->
    html = "<li class='dz-preview dz-image-preview' data-uploaded='true'>
      <img data-dz-thumbnail='' height='100' src='data:image/jpeg;base64,#{URI}'>
      <div class='font-awesome delete'><div>&#xf00d;</div></div>
    </li>"
    @$filePreview.append html


  setModel: ->
    # Start grabbing the files from the drop-zone
    files = @files

    # Append each file into the model
    @model.attributes.files = []
    for file in files
      @model.attributes.files.push file

    @model.set 'filesToDelete', @filesToDelete


  setDOM: ->
    images = @model.get 'images'
    for image in images then @addImage image.file