module.exports = Backbone.View.extend
  name: '[view:classified-post:submit]'
  template: template['classified/post/submit']

  start: (options) ->
    @$submit  = @$ '.submit'

  validate: -> true