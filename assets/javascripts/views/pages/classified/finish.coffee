module.exports = Backbone.View.extend
  name: '[view:classifieds-finish]'
  template: template['classified/finish']
  templateOptions: isGuest: false

  title: -> "Classified submitted!"

  events:
    'click #promoteLink': 'promoteHandle'

  paywithatweetURL: 'http://www.paywithatweet.com/pay?id=839c89ba-fec9-4b31-8f0a-29043cee27b6'
  # messages: perkpaid: 'Your perk is now activated'

  # perkPrices: [
  #   {
  #     price: 5
  #     toggled: false
  #   }
  #   {
  #     price: 15
  #     toggled: false
  #   }
  # ]

  start: (options) ->

    # Setup DOM variables
    @$tabPayment    = @$ '#tab-payment'
    @$paymentErrors = @$ '#payment-errors'
    @$modal         = @$ '#modal-purchase'

    @$authLink    = @$ "#authLink"
    @$finishLink  = @$ "#finishLink"
    @$facebook    = @$ ".social.facebook"
    @$twitter     = @$ ".social.twitter"
    @$gplus       = @$ ".social.gplus"

    @$sharedMessage = @$ "#shared-message"
    @$unsharedMessage = @$ "#unshared-message"

    cookieHelper = @resources.Helpers.cookie
    cookieHelper.eraseCookie 'pay-w-tweet'
    cookieHelper.eraseCookie 'authHash'

    if (window.location.hash.indexOf "shared") != -1
      @$sharedMessage.show()
      @$unsharedMessage.hide()
    else
      @$sharedMessage.hide()
      @$unsharedMessage.show()

  continue: -> @generateSocialLinks()

  # Generates the social links to share the classified (twitter/facebook/gplus)
  # and sets them into the DOM.
  generateSocialLinks: ->
    id = @resources.historyState.parameters
    URL = "#{window.location.origin}/classified/#{id}"
    localURL = "/classified/#{id}"

    tweet    = "Check out my classified at #{URL}"
    facebook = "https://www.facebook.com/sharer/sharer.php?u=#{URL}"
    twitter  = "https://twitter.com/home?status=#{encodeURI tweet}"
    gplus    = "https://plus.google.com/share?url=#{URL}"

    @$authLink.html            localURL
    @$authLink   .attr 'href', localURL
    @$finishLink .attr 'href', localURL
    @$facebook   .attr 'href', facebook
    @$twitter    .attr 'href', twitter
    @$gplus      .attr 'href', gplus


  promoteHandle: ->
    cookieHelper = @resources.Helpers.cookie
    cookieHelper.createCookie 'pay-w-tweet', @resources.historyState.parameters
    window.location = @paywithatweetURL

  # parseURL: ->
    # getParam = @resources.helpers.url.getParam
    # if getParam 'error'   then app.error @messages[getParam 'error']
    # if getParam 'success' then app.success @messages[getParam 'success']
    # if getParam 'warn'    then app.warn @messages[getParam 'warn']


  # managePayment: (e) ->
  #   $el = $(e.currentTarget)
  #   type = $el.data().val
  #   price = 0
  #   $el.parent().toggleClass 'switch'
  #   perk = @perkPrices[type]
  #   perk.toggled = !perk.toggled
  #   $('[name=\'perk-' + type + '\'').val perk.toggled
  #   $el.parent().toggleClass 'active', perk.toggled
  #   @perkPrices[type] = perk
  #   if @perkPrices[0].toggled
  #     price += @perkPrices[0].price
  #   if @perkPrices[1].toggled
  #     price += @perkPrices[1].price
  #   $('#classified-sample li').toggleClass 'perk-urgent', @perkPrices[0].toggled
  #   if price == 0 then @$tabPayment.hide()
  #   else @$tabPayment.show()
  #   @$tabPayment.find('.total span').html price


  # validateCreditDetails: (credit) -> true


  # getCreditDetails: ->
  #   {
  #     ccNo: $('#ccc').val()
  #     cvv: $('#cvv').val()
  #     expMonth: $('#cmdate').val()
  #     expYear: $('#cydate').val()
  #     billingAddr:
  #       city: $('#ccity').val()
  #       addrLine1: $('#caddr1').val()
  #       addrLine2: $('#caddr2').val()
  #       country: $('#ccountry').val()
  #       email: $('#cemail').val()
  #       name: $('#cname').val()
  #       phoneNumber: $('#cphone').val()
  #       state: $('#cstate').val()
  #       zipCode: $('#czip').val()
  #   }




  # makePurchase: (e) ->
  #   e.preventDefault()
  #   _2checkout = @data._2checkout
  #   credit = @getCreditDetails()

  #   # Called when token creation fails.
  #   errorCallback = (response) ->
  #     console.error 'Could not get a transaction token' + response.errorMsg
  #     controller.$modal.removeClass 'switch'
  #     controller.showPaymentError 'Some fields are missing'
  #     # if response.errorCode == 200
  #       # This error code indicates that the ajax call failed
  #       # Recommend to retry the token request.


  #   # Called when token creation was successful
  #   successCallback = (data) ->
  #     token = data.response.token.token
  #     credit.token = token
  #     controller.sendTokenBackend credit
  #     return

  #   # Get the credit card details
  #   if @validateCreditDetails(credit)
  #     credit.sellerId = _2checkout.sid
  #     credit.publishableKey = _2checkout.publicKey
  #     controller.$modal.addClass 'switch'

  #     # Load the public key
  #     TCO.loadPubKey 'sandbox', ->

  #       # Request for the token and then send it to the backend
  #       TCO.requestToken successCallback, errorCallback, credit
  #       return
  #   else console.log 'invalid credit details'


  # showPaymentError: (message) -> @$paymentErrors.show().html message


  # sendTokenBackend: (credit) ->
  #   data =
  #     _csrf: window._csrf
  #     _id: @post._id
  #     billingAddr: credit.billingAddr
  #     perks: [
  #       @perkPrices[0].toggled
  #       @perkPrices[1].toggled
  #     ]
  #     token: credit.token
  #   controller.$modal.addClass 'switch'

  #   # Perform AJAX call
  #   $.ajax
  #     type: 'POST'
  #     url: document.URL
  #     data: data
  #     dataType: 'json'
  #     success: (response) ->
  #       if response.status == 'success'
  #         window.location = '?success=perkpaid#'
  #       else
  #         console.error 'Payment could not be processed', response, error
  #         controller.showPaymentError 'Your credit details could not be authorized'
  #       controller.$modal.removeClass 'switch'