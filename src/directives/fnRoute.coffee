###*
 * This directive is responsible for properly routing the app, when it using
 * HTML5's pushstate or fall-back hash URLs.
 *
 * This way, we can deploy the app into PhoneGap application (which use
 * hashbang URLs) without rewriting the links and have the entire app navigate
 * properly.
###
exports = module.exports = ($location)->
  link: (scope, element, attributes) ->
    # Initialize.
    element = attributes.$$element[0]
    url = attributes.fnRoute

    # On click, redirect the page using the $location service.
    onClick = -> scope.$apply -> $location.url url
    (angular.element element).bind "click", onClick


exports.$inject = ["$location"]
