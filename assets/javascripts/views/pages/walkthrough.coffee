# The privacy policy page. Nothing interesting here
module.exports = (require '../mainView').extend
	name: '[view:walkthrough]'
	bodyid: 'walkthrough'
	template: template['walkthrough']

	start: ->
		$window = $ window
		$img = @$ 'img'
		$img.height $window.height() - 150

	continue: ->
		($ document).foundation 'orbit', 'reflow'