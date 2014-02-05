@PINGO.events = {}
@PINGO.events.vars = {}

@PINGO.events.updateConnectedUsers = (event, selector, container) ->
	jQuery.ajax( "/events/" + event.toString() + "/connected"  )
		.done (data) ->
			if data.indexOf("-") is -1
				jQuery(selector).text( ( if data == "0" then "" else "ca. " ) + data)
				jQuery(container).show()
			return
		.fail ->
			jQuery(container).hide()
			return
		
	

@PINGO.events.startConnectedUsersUpdate = (event, selector, container, seconds) ->
	window.setInterval(() -> 
		window.PINGO.events.updateConnectedUsers(event, selector, container)
		return
	, seconds * 1000)
	
@PINGO.events.updateSurveyTable = (container, url) ->
	jQuery(container).load url

@PINGO.events.loadSurvey = (event_survey_url) ->
	jQuery.getScript event_survey_url

@PINGO.events.addQuestionDurationModal = (url, question_id, modal_id) ->
	$modal = jQuery(modal_id)
	$modal.find("#duration_question").val(question_id)
	$modal.find("#duration_modal_form").attr("action", url)
	$modal.modal('show')