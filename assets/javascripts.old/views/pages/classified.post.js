module.exports = Backbone.View.extend({
	model: new app.models.classified,

	events: {
		"click .dz-preview .delete div" : "removeFile",
		"click .submit" : "submit",
		"click #image-upload .camera" : "getImageFromCamera",
		"click #image-upload .gallery" : "getImageFromGallery",
		"click .nav-next" : "validatePage",
		"change #cat-selector" : "catSelected",
		"change #price-selector" : "priceSelected",
		"change #locations" : "unlockMapAndAddress"
	},

	initialize: function(obj) {
		window.controller = this;

		/* Setup our DOM variables */
		controller.$description = controller.$el.find("#description");
		controller.$filePreview = controller.$el.find("#image-upload-preview");
		controller.$gmap = controller.$el.find("#map-canvas");
		controller.$gmapX = controller.$el.find("[name='gmapX']");
		controller.$gmapY = controller.$el.find("[name='gmapY']");
		controller.$locations = controller.$el.find("#locations");
		controller.$parCategory = controller.$el.find("#cat-selector");
		controller.$priceField = controller.$el.find('#price-field');
		controller.$priceSelector = controller.$el.find("#price-selector");
		controller.$subCategory = controller.$el.find("#subcat-selector");
		controller.$submit = controller.$el.find(".submit");

		/* Initialize parts of the form */
		controller.render();
		controller.initCategories();
// /		controller.initDropzone();
		controller.initLocations();
		// controller.$description.redactor();
		controller.spinner = new app.views.components.spinner();

		/* Enable smooth scroll */
		app.libs.smoothScroll.init();

		/* Resize the pages whenever the window resizes */
		$(window).resize(controller.render);
	},


	/**
	 * [render description]
	 */
	render: function() {
		$(".page").css("min-height", $(window).height());
		$("#main-container").fadeIn();
	},


	/**
	 * Checks all the required fields in that particular page and prevents the
	 * page from scrolling if any of the fields are empty.
	 *
	 * @param  {[type]} e [description]
	 * @return {[type]}   [description]
	 */
	validatePage: function (e) {
		e.preventDefault();

		var $el = $(e.currentTarget);
		var $parent = $el.parent().parent();
		var $els = $parent.find("[required]");
		var valid = true;

		/* First clear off all the errors */
		controller.removeErrors();

		$els.each(function(i) {
			var $el = $els.eq(i);
			var val = $el.val();

			$el.removeClass('error');
			if(!val || val == '') {
				valid = false;
				$el.addClass('error');
			}
		});

		if(valid) app.libs.smoothScroll.animateScroll(null, $el.attr('href'));
		else controller.addError($parent, "Some of the fields are missing");
	},


	/**
	 * Validates the form data and returns true, iff the form data is valid for
	 * submission.
	 */
	validateForm: function(data) {
		var $els = controller.$el.find("[required]");
		var $captcha = $('#g-recaptcha-response');
		var $parent = $captcha.parent().parent().parent();
		var valid = true;

		/* First clear off all the errors */
		controller.removeErrors();

		$els.each(function(i) {
			var $el = $els.eq(i);
			var val = $el.val();

			$el.removeClass('error');
			if(!val || val == '') {
				valid = false;
				$el.addClass('error');
			}
		});


		if(!valid) controller.addError($parent, "Please fill in the missing fields");
		if($captcha.val().length <= 0) {
			controller.addError($parent, "The captcha failed to pass");
			valid = false;
		}

		return valid;
	},


	/**
	 * [addError description]
	 *
	 * @param {[type]} $el     [description]
	 * @param {[type]} message [description]
	 */
	addError: function($el, message) {
		$el.find("ul.error-message").append(
			"<li>" + message + "</li>"
		);
	},


	/**
	 * [removeErrors description]
	 *
	 * @param  {[type]} $el [description]
	 * @return {[type]}     [description]
	 */
	removeErrors: function($el) {
		controller.$el.find("ul.error-message li").remove();
	},


	/**
	 * Sends the AJAX request to the back-end
	 */
	submit: function(event) {
		event.preventDefault();

		/* Get and validate the form data */
		var data = controller.getFormData();
		// if(!controller.validateForm(data)) return;

		/* Start submitting the form */
		var $captcha = $('#g-recaptcha-response');
		var $parent = $captcha.parent().parent().parent();

		controller.$submit.hide();
		controller.spinner.show();

		/* Send the AJAX request and redirect */
		$.ajax({
			url: document.URL,
			beforeSend: function (request) {
				request.setRequestHeader("g-captcha", $captcha.val());
				request.setRequestHeader("xsrf-token", window._csrf);
            },
			contentType: false,
			data: data,
			processData: false,
			type: "POST",
			success: function(response) {
				console.log(response);

				switch(response.status) {
					case "success": controller.ajaxSuccess(response); break;
					case "notsaved": controller.addError($parent, 'The classified was not saved. Some of the fields are invalid'); break;
					default: /* Handle errors here */
				};

				controller.$submit.show();
				controller.spinner.hide();
			},
			error: function(response) {
				controller.addError($parent, 'Something went wrong');
				controller.$submit.show();
				controller.spinner.hide();
			}
		});
	},


	/**
	 *
	 * @param  {[type]} response [description]
	 * @return {[type]}          [description]
	 */
	ajaxSuccess: function(response) {
		/* Create the finish URL */
		var href = "/classified/finish/" + response.id;
		if(response.authHash) href += "?authHash=" + response.authHash;

		/* Redirect to this URL */
		window.location.href = href;
	},


	/**
	 * Handler function to remove the file from the Uploads queue.
	 */
	removeFile: function(event) {
		/* Find the index of the file */
		var $el = $(event.currentTarget);
		var index = $el.parent().parent().index();

		/* Remove it from the DOM */
		controller.$filePreview.find("li").eq(index).remove();

		/* Remove it from the file Queue */
		controller.dropzone.files[index].status = "delete";
	},


	/**
	 * Handler function to change the price boxes
	 */
	priceSelected: function(event) {
		var val =  controller.$priceSelector.find(":selected").val();
		switch(val) {
			case "Free":
				controller.$priceField.val(0);
				controller.$priceField.addClass('hide');
				break;
			case "Custom":
				controller.$priceField.val(null);
				controller.$priceField.removeClass('hide');
				break;
			case "Contact Owner":
				controller.$priceField.val(-1);
				controller.$priceField.addClass('hide');
				break;
		}
	},


	/**
	 * Generates the HTML code for a select option.
	 */
	generateOption: function(id, name, disabled) {
		if(disabled)
			return "<option data-id='-1' value='-1' disabled>" + name +
				"</option>";
		return "<option data-id='" + id + "' value='" + id + "'>" + name +
			"</option>";
	},


	/**
	 * Handler function to change the subcategory select box based on the parent
	 * select option.
	 */
	catSelected: function(e) {
		var id = controller.$parCategory.find(":selected").data("id");
		var categories = window.categories;

		controller.$subCategory.show();
		controller.$subCategory.removeAttr("disabled");

		for(var i=0; i<categories.length; i++)
			if(categories[i]._id == id) {
				var children = categories[i].children;

				controller.$subCategory.html(
					controller.generateOption(0, "Choose a sub-category", true)
				);
				for(var j=0; j<children.length; j++) {
					var html = controller.generateOption(children[j]._id,
						children[j].name);
					controller.$subCategory.append(html);
				}

				return;
			}
	},


	/**
	 * Unlocks the map and address fields.
	 */
	unlockMapAndAddress: function(e) {
		var lastVal = controller.$locations.find('option:last-child').val();

		/* Check if we selected the last option or not. If we have, then disable
		 * the map and the address fields */
		if(controller.$locations.val() != lastVal) {
			$("[name='address1']").removeClass("hide");
			$("[name='address2']").removeClass("hide");
			$("#page-4").removeClass("hide");
			$("#page-4-prev, #page-4-next").attr('href', '#page-4');
			controller.initMaps();
		} else {
			$("[name='address1']").addClass('hide');
			$("[name='address2']").addClass('hide');
			$("#page-4").addClass("hide");
			$("#page-4-prev").attr('href', '#page-3');
			$("#page-4-next").attr('href', '#page-5');
		}
	},


	/**
	 * Initializes the categories option.
	 */
	initCategories: function() {
		controller.$subCategory.hide();
		controller.$parCategory.val(0);

		var categories = window.categories;
		for(var i=0; i<categories.length; i++) {
			var html = controller.generateOption(categories[i]._id, categories[i].name);
			controller.$parCategory.append(html);
		}
	},


	/**
	 * Initializes the locations.
	 */
	initLocations: function () {
		var locations = window.locations;
		for(var i=0; i<locations.length; i++) {
			var html = controller.generateOption(locations[i]._id, locations[i].name);
			controller.$locations.append(html);
		}
	},


	/**
	 * Initializes the drop-zone.
	 */
	getImageFromCamera: function() {
		// return console.log("from camera");

		navigator.camera.getPicture(onSuccess, onFail, {
			quality: 50,
		    destinationType: Camera.DestinationType.FILE_URI,
		    sourceType : Camera.PictureSourceType.CAMERA
		});

		function onSuccess(imageData) {
			// var image = document.getElementById('myImage');
			alert(imageData);
			// image.src = "data:image/jpeg;base64," + imageData;
		}

		function onFail(message) {
			// alert('Failed because: ' + message);
		}
	},

	getImageFromGallery: function (argument) {
		navigator.camera.getPicture(onSuccess, onFail, {
			quality: 50,
		    destinationType: Camera.DestinationType.FILE_URI,
		    sourceType : Camera.PictureSourceType.PHOTOLIBRARY
		});

		function onSuccess(imageData) {
			var image = document.getElementById('myImage');
			image.src = "data:image/jpeg;base64," + imageData;
		}

		function onFail(message) {
			// alert('Failed because: ' + message);
		}
	},


	/**
	 * Gets all the form data from the page, into a local variable and returns
	 * it.
	 */
	getFormData: function() {
		var $form = controller.$el.find("#image-form");

		/* Get the files and perform a nice little hack on the AJAX upload */
		// var files = controller.dropzone.getQueuedFiles();
		if(files.length == 0) $form.append('<input name="files[]" type="file" class="hide" />');

		/* Create the form data object */
		var formData = new FormData($form[0]);

		this.model.attributes.files = [];

		/* Start grabbing the files from the drop-zone */
		for (var i = 0; i < files.length; i++) {
			var file = files[i];

			/* Add the file to the request. */
			this.model.attributes.files.push(file);
			formData.append('files[]', file, file.name);
		}

		return formData;
	},


	/**
	 * Initializes Google maps
	 */
	initMaps: function() {
		/* The default co-ordinates to which we will center the map */
		var myLatlng = new google.maps.LatLng(29.27985, 47.98448)

		/* Initialize the map */
		controller.gmap = new google.maps.Map(controller.$gmap[0], {
			center: myLatlng,
			mapTypeControl: false,
			mapTypeId: google.maps.MapTypeId.ROADMAP,
			scrollwheel: false,
			draggable: false,
			zoom: 13,
		});

		/* Initialize the marker */
		controller.gmarker = new google.maps.Marker({
			draggable: true,
			map: controller.gmap,
			position: myLatlng
		});

		/* Add a listener to center the map on the marker whenever the
		 * marker has been dragged */
		google.maps.event.addListener(controller.gmarker, 'dragend',
			function (event) {
				/* Center the map on the position of the marker */
				var latLng = controller.gmarker.getPosition();
				controller.gmap.setCenter(latLng);

				/* Set our hidden input fields so that thecontroller. backend can catch
				 * it */
				controller.$gmapX.val(latLng.lat());
				controller.$gmapY.val(latLng.lng());
		});
	},
});