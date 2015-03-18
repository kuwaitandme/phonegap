module.exports = Backbone.View.extend({
	bodyId: "auth-login",
	events: {
		"click .submit" : "submit",
	},
	messages: {
		activate_fail: 'Something went wrong while activating your account',
		activate_success: 'Your account is successfully activated',
		captchaFail: 'Please enter the captcha properly!',
		inactive: 'Your account is not activated! Check your inbox (and junk email) for an activation email',
		incorrect: 'Your login credentials are invalid',
		logout: 'You have been logged out successfully',
		need_login: 'You need to be logged in in to view that page',
		reset_error: 'Something went wrong while resetting your password',
		reset_password_mismatch: 'The passwords have to match',
		reset_password_small: 'The password is too small (min 6 characters)',
		reset_sent: 'Password reset has been sent to your email',
		reset_success: 'Your password has been reset',
		send_again: 'Your account is not activated, check your email',
		signup_fail: 'Something went wrong while registering you',
		signup_invalid: 'Some of the fields are invalid',
		signup_success: 'Your account has been created, Check your inbox (and junk email) for an activation email',
		signup_taken: 'That account name has already been taken!'
	},

	initialize: function() {
		/* Parse the URL and give out the appropriate message based on it. */
		var msg = app.messages;
		var getParam = app.helpers.url.getParam;

		this.$error = $('#error');

		if(getParam('error')) msg.error(this.messages[getParam('error')]);
		if(getParam('success')) msg.success(this.messages[getParam('success')]);
		if(getParam('warn')) msg.warn(this.messages[getParam('warn')]);
		this.render();
	},

	render: function() {
		$("#main-container").fadeIn();
	},

	submit: function(event) {
		var that = this;
		var $el = $(event.currentTarget);

		var $required = $el.parent().parent().find('[required]');
		$required.each(function(i) {
			$r = $required.eq(i);

			if(!$r.val() || $r.val().length == 0) {
				event.preventDefault();
				return that.showError('Please fill in all the fields');
			}

		});
	},

	showError: function(error) {
		this.$error.html('<li>' + error + '</li>');
	},

	hideError: function() {
		this.$error.html('');
	}
});