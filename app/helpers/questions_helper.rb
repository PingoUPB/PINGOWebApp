module QuestionsHelper
  def link_to_export(text, type)
    link_to_function text, "$(this).closest('form').find('input[name=\"export_type\"]').val('#{type}'); $(this).closest('form').submit()"
  end
  
  def link_to_function(name, function, html_options={})
          message = "link_to_function is deprecated and will be removed from Rails 4.1. We recommend using Unobtrusive JavaScript instead. " +
            "See http://guides.rubyonrails.org/working_with_javascript_in_rails.html#unobtrusive-javascript"
          ActiveSupport::Deprecation.warn message

          onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
          href = html_options[:href] || '#'

          content_tag(:a, name, html_options.merge(:href => href, :onclick => onclick))
  end
end
