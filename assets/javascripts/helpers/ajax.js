module.exports = {
	setHeaders: function (request) {
		request.setRequestHeader("x-ajax", 'json');
		request.setRequestHeader("x-csrf-skipper", true);
	}
}