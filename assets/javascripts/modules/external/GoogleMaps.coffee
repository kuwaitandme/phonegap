module.exports = class GoogleMaps
  name: "[google-maps]"

  constructor: ->
    console.log @name, 'initializing'
    @onLoad => console.log @name, 'loaded'

  onLoad: (callback=->) ->
    waitForElement = ->
      if window.google? and
      window.google.maps? and
      window.google.maps.Circle? then callback()
      else setTimeout (-> waitForElement()), 250
    waitForElement()