module QuestionsHelper
  def link_to_export(text, type)
    link_to_function text, "$(this).closest('form').find('input[name=\"export_type\"]').val('#{type}'); $(this).closest('form').submit()"
  end
end
