class CollabCtrl
	constructor: (fieldSelector, listSelector) ->
		@collabField = jQuery(fieldSelector)
		@listElem = jQuery(listSelector)
		@collaborators = @collabField.val().split(",")

	updateField: ->
		@collabField.val @collaborators.join(",")

	addToList: (user) ->
		@listElem.append "<li class=\"collaborators__item\"><strong>#{user.name}</strong> (#{user.email}) <a href=\"#\" data-id=\"#{user.id}\" class=\"remove-collaborator collaborators__action\">#{window.PINGO.collaborators.locales.remove}</a></li>"

	addUser: (user) ->
		if jQuery.inArray(user.id, @collaborators) < 0 # o.O
			@collaborators.push user.id
			@updateField()
			@addToList user

	removeUser: (userId) ->
		@collaborators = @collaborators.filter (id) -> id isnt userId
		@updateField()


if $(".collaborators-form").length > 0
	ctrl = new CollabCtrl(".collaborators-form", "#collaborators-list")
	
	removeCollaborator = (e) ->
		ctrl.removeUser $(this).data "id"
		$(this).parent().remove()
		e.preventDefault()
		return
		
	$(document).on("click", ".remove-collaborator", removeCollaborator)
	
if $(".collaborators-form").length > 0 or $("#shareModal").length > 0
	submitForm = (e) ->
		email = $("#mail_for_collaborators").val()
		
		$.getJSON("/api/find_user_by_email", {
				"email": email
			}, (data) ->
				if $(".collaborators-form").length > 0 # single form
					ctrl.addUser(data)
					$("#collaborators_feedback").text("")
					$("#collaborators_feedback").fadeOut()
				else # modal form
					$("#mail_for_collaborators").val("")
					$("#collaborators_wait").show()
					$("#export_question_form").attr('action', '/questions/share')
					$("#export_question_form").find('input[name=\"share_user_id\"]').val(data.id)
					$("#export_question_form").submit()
				return
		).fail () ->
			$("#collaborators_feedback").text(window.PINGO.collaborators.locales.not_found)
			$("#collaborators_feedback").fadeIn()
		
		e.preventDefault()
		return		
	
	$(document).on("click", "#collaborator-search", submitForm)
	$(document).on("keyup", "#mail_for_collaborators", (e) ->
		if (e.keyCode is 13)
			submitForm(e)
	)