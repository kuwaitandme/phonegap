module.exports = Backbone.View.extend
  name: '[view:home]'
  bodyid: 'home'
  template: template['home']

  events: "submit" : "formSubmit"

  start: ->
    @$categoryContainer = @$ '#categories'
    @$classifiedList = @$ ".classifiedList"
    @$logo = @$ "#landing-logo img"

    # @classifiedList = new @resources.Views.components.classifiedList
    #   settings:
    #     isAccount: false
    #     enableFilterBox: false
    #   resources: @resources
    #   el: @$classifiedList
    # @classifiedList.trigger 'start'

    # @$categoryList.hide()

    @$categoryList = @$el.find '#masonry-container .content'
    @categoryList = new @resources.Views.components.categoryList
      el: @$categoryContainer
      resources: @resources
    @categoryList.trigger 'start'

  continue: ->
    # Facebook = new @resources.external.Facebook
    # Facebook.onLoad -> FB.XFBML.parse()

    @categoryList.trigger 'continue'


  pause: -> @categoryList.trigger 'pause'


  # This function redirects the app to the classified search page, with the
  # text in the search box set as the keywords in the GET query.
  formSubmit: (event) ->
    event.preventDefault()
    $keywords = @$ "[name='keywords']"

    # Get the keywords and covert it into a GET query
    text = $keywords.val().replace ' ', '+'

    # Redirect the app to the classified search page.
    url = "#{@resources.language.urlSlug}/classified?keywords=#{text}"
    @resources.router.redirect url