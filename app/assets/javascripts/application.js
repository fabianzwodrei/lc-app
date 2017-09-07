// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

//= require bootstrap-sprockets
//= require bootstrap3-typeahead.min
//= require bootstrap-datepicker/core
//= require bootstrap-datepicker/locales/bootstrap-datepicker.de.js



$(document).on('turbolinks:click', function () {
	// Removing modal when leaving, so it wont appear when coming back (back-btn)
	if ($('#theModal').hasClass('show')) {
		$('#theModal').removeClass('show').hide();
		$('body').removeClass('modal-open');
		$('.modal-backdrop').remove();
	}	
});

$(document).on("turbolinks:load", function() {

	
	$('#theModal').on('show.bs.modal', function (event) {
		$(this).find('.modal-body').load($(event.relatedTarget).data('href'))
		
	})
	$('#theModal').on('hidden.bs.modal', function (event) {
		$(this).find('.modal-body').empty();
	})


	$('[data-toggle="tooltip"]').tooltip();

	if ($('#cable_conversation').length) {
		// console.log(" - - - - #cable_conversation")
		var conversation_identifier = {channel: "ConversationChannel", conversation_id: $('#cable_conversation').data().conversationId};

		if (App.conversation) {
			if (App.conversation.identifier != JSON.stringify(conversation_identifier)) {
				App.cable.subscriptions.remove(App.conversation);
				// console.log("removing old subscription")
				delete App.conversation
			}
		}
		if ( App.conversation == undefined ) {
			// console.log("trying to connect")
			App.conversation = App.cable.subscriptions.create(conversation_identifier, {
				// connected: function () {
				// 	console.log("connected")
				// },
				// disconnected: function () {
				// 	console.log("disconnected")
				// },
				// rejected: function () {
				// 	console.log("rejected")
				// },
				received: function(data) {
					if ($('#cable_conversation').data().prependMessage == true) {
						$('#messages').prepend(data['message']);
					} else {
						$('#messages').append(data['message']);
						window.scrollTo(0, document.body.scrollHeight);
					}
					$('.message_thread_link').click(function(event){
						this.href = this.href + "?origin=" + window.location.pathname;
					});
				}
			});
		}

		$('.message_thread_link').click(function(event){
			this.href = this.href + "?origin=" + window.location.pathname;
		});




		$('#message_form').submit(function(event) {
			event.preventDefault();
			if ($('#message_text').val() == "") return false;
			var form = new FormData(this);
			$.ajax({
	    		url: this.action,
	    		method: 'POST',
	    		data: form,
	    		cache: false,
				contentType: false,
				processData: false,
	    		success: function(response) {
	    			$('#upload_button').text("Datei");
					$('#message_attachment').val("");
					$('#message_text').val("");
	    		},
	    		error: function (err) {
	    			alert("Fehler: " + err.responseText);
	    		}
	    	});
		});
	}

	$('#upload_button').click(function(){
		var attachment = $('#message_attachment')
		if (attachment.val() == "") {
			attachment.click();
		} else {
			$(this).text("Datei");
			attachment.value == "";
		}
		return false;
	});

	if ($('#info_mail_form').length) {
		$('#info_mail_form').submit(function(event) {
			event.preventDefault();
			if ($('#email_body').val() == "" || $('#email_subject').val() == "") {
				alert("Bitte beide Email-Felder ausfüllen")
				return false;
			}

			var form = new FormData(this);
			$.ajax({
	    		url: this.action,
	    		method: 'POST',
	    		data: form,
	    		cache: false,
				contentType: false,
				processData: false,
	    		success: function(response) {
	    			$('#info_mail_form').html("Email(s) wurden gesendet");
	    		},
	    		error: function (err) {
	    			alert("Fehler: " + err.responseText);
	    		}
	    	});
		});

	}


});