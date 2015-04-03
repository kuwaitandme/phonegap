module.exports = Backbone.View.extend
  sliderAnimateWidth: 200
  template: template['auth/choose']
  events:
    'click #grabber-hide': 'hide'
    'click #grabber-display': 'show'
    'click ul a': 'hide'
    "click #close-button" : 'toggleAuth'
    'click #nav-grabber' : 'toggleAuth'


  initialize: (options) ->
    # Initialize DOM variables
    @$navHome      = @$ '#nav-logo'
    @$navLinks     = @$ '.nav'
    @$nextLink     = @$ '.next'
    @$previousLink = @$ '.prev'
    @$body         = $ 'body'
    @$sliderNav    = @$ '#slider-nav'

    $("[data-show-auth").click => @toggleAuth()
    # @listenTo app.models.currentUser, 'sync', @update
    @render()


  render: -> @$el.html @template()

  toggleAuth: -> @$body.toggleClass 'show-auth'