exports = module.exports = ($window)->
  link: (scope, element, attributes) ->
    element = attributes.$$element[0]
    url = attributes.pgHref

    onClick = -> $window.open url, "_system"
    (angular.element element).bind "click", onClick


exports.$inject = ["$window"]
