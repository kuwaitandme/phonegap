# local config (make sure it is ignored by git)
#
# This configuration file is specific to each developer's environment,
# and will merge on top of all other settings from ./config.js
# (but only will merge in development environment)
exports = module.exports = ->
  cache: false
  sitename: "Kuwait and Me"
  staticUrl: "https://development.kuwaitandme.com"
  url: "https://development.kuwaitandme.com"
  server:
    cluster: false
    port: 3000

  facebook: oauth:
      clientID: "398948180288474"
      clientSecret: "995fce109705d856fe94ad1dc0128952"

  twitter:
    oauth:
      consumerKey: "dpQcjGDL7Ih8JmETnlZP28bYu"
      consumerSecret: "s1amDz0gIt917RhnkddsDWyTXVZAhjbm7n89rXT7CXE4tKZ10g"
    user: "@kuwaitandme"

  google:
    analyticsCode: null
    oauth:
      clientID: "384211238362-m00ec6d0up75dov8qaub8m7kods88ktq.apps.googleusercontent.com"
      clientSecret: "Sg78VqA3QvAhwjm6V-PalT5W"

  windowslive: oauth:
    clientID: "000000004414F52F"
    clientSecret: "0t3GEEDGsfGe9iBvtSVFq9TImZRN54bw"

  wordpress: oauth:
    clientID: "40897"
    clientSecret: "WtEgz6QwgbZhtyJJHdOF1D0SIbW8wPSLOEXjDvDXJANVzIvBGbVfBhkGZwXOpk4T"

  linkedin: oauth:
    consumerKey: "77hqupym5x94qa"
    consumerSecret: "trGYyChTxZkzAkuX"
    profileFields: [
      "id"
      "email-address"
      "first-name"
      "last-name"
    ]

  amazon: oauth:
    clientID: "amzn1.application-oa2-client.023ce50dadd44e798ebf99df9cf932e8"
    clientSecret: "2c2b49a11d0fa9e1432ff72b2c95f002bbabd63dd4a53d73ec1e71530a65a00e"

  reddit: oauth:
    clientID: "gTMDedJDgtf3Ow"
    clientSecret: "B8TtG2mjcbyNHTav2OfSCXYwYAQ"

  session: secret: "3cc5ef91eb2935e2c166681c350937a3"

  email:
    noreplyAddress: "noreply@kuwaitandme.com"
    webmasterAddress: "webmaster@kuwaitandme.com"
    smtp:
      hostname: "smtp.gmail.com"
      password: "mh76N*&="
      ssl: true
      username: "noreply@kuwaitandme.com"

  paypal:
    client_id: "ARg_x-kqxgCw9yK2d9stx9jX9EGV8gONmrfXoAUHOJd8BofyhTNvmexlQIo8JDFuwWthgrM77hljnaDu",
    client_secret: "EPVxN7w2mXezQ0L5r_ukFEoUG_vTbJ0Sibv6jXJCqyDkirYe0c4OLS9TC8MFol_ozjDta-zs3NVhjZrX"
    enabled: true
    host: "api.sandbox.paypal.com"

exports["@singleton"] = true