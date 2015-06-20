exports = module.exports = -> new class
  name: "[provider:environment]"

  # This function is called by Angular when this provider is first invoked. Here
  # we base64 decode the cryptedData variable and we also merge in the values
  # from the publicData variable. This way we encapsulate all the settings that
  # the server gives us in a single provider.
  $get: [
    "$window"
    "$log"
    "$base64"
    ($window, $log, $base64) ->
      $log.log @name, "initializing"
      config = {}
      try
        # Decode the cryptedData and extend the properties of the publicData
        # object
        angular.extend config, $window.publicData
        return config
      catch e
        $log.error @name, "error decoding server-side data"
        $log.error e
        return config
  ]
