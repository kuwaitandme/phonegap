module.exports = Backbone.View.extend({
	bodyId: "landing",

	initialize: function() {

		// device APIs are available
		//
		// var device = window.device || {};
		// var innerHTML = 'Device Model: '    + device.model    + '<br />' +
		// 					'Device Cordova: '  + device.cordova  + '<br />' +
		// 					'Device Platform: ' + device.platform + '<br />' +
		// 					'Device UUID: '     + device.uuid     + '<br />' +
		// 					'Device Version: '  + device.version  + '<br />';
		// document.write(innerHTML);
		this.render();
	},

	render: function() {
		$("#main-container").fadeIn();
	},
});