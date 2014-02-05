module ViewHelper
  def gravatar_for email, options = {}
    # http://stackoverflow.com/questions/770876/5043452#5043452
    options = {:alt => 'Gravatar', :class => 'avatar', :size => 80}.merge! options
    id = Digest::MD5::hexdigest email.strip.downcase
    url = 'http://www.gravatar.com/avatar/' + id + '.jpg?s=' + options[:size].to_s
    options.delete :size
    image_tag url, options
  end
  
  def mathjax_tag
    '<script 
       src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
    </script>'.html_safe
  end
  
  def error_msg_for(obj)
    if obj.errors.any?
      content_tag(:div, id: "error_explanation") do
        content_tag(:h5, t("there_were_errors_saving") + ":") + 
        content_tag(:ul, (obj.errors.full_messages.map do |msg|
            content_tag(:li, msg)
          end.join.html_safe)
        ) # ul
      end # div
    end
  end
end