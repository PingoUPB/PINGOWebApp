@PINGO.surveys = {}
@PINGO.surveys.vars = {}

@PINGO.surveys.getAnswerOptionsForType = (typ) ->
  if typ is "choice"
    window.PINGO.surveys.vars.choice_answers
  else if typ is "text"
    window.PINGO.surveys.vars.text_answers
  else
    null

jQuery(document).ready () ->
  jQuery(".type-radio").change () ->
    if jQuery(this).prop("checked")
      options = window.PINGO.surveys.getAnswerOptionsForType(jQuery(this).data("survey-type"))
      if options
        jQuery(this).parents("form").find(".options_container").show()
        jQuery(this).parents("form").find(".answer-options-select").html(options)
      else
        jQuery(this).parents("form").find(".options_container").hide()
    return
  jQuery(document).on "click", ".dropdown-menu.close-on-click li a", (e)->
    jQuery(this).parents("ul.dropdown-menu").first().parent().toggleClass("open") # FIXME might break in future bootstrap versions
    return


  # templates for single question choices
  jQuery("#choice_templates").change (event) ->
    # get translated options
    options = window.PINGO.QuestionTpls[jQuery(this).val()]

    # get number of currently available options
    num_option_fields = jQuery("#option_controls").children('.control-group').length

    jQuery.each options, (index, option) ->
      if index >= num_option_fields
        jQuery('a#add_single_option').trigger 'click' # add option

      # update number of children
      num_option_fields = jQuery("#option_controls").children('.control-group').length

    # set values accordingly
    jQuery('#option_controls input[type=text]').val (index, val) ->
      options[index]

    # reset select choice
    $(this).children("option").first().attr("selected", "selected")
    return
  return




