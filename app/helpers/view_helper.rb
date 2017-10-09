module ViewHelper
  def mathjax_tag
    '<script type="text/javascript" src="//cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>'.html_safe
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
  
  def push_script_tag(sample_hosts=false) # if sample_hosts is true, 80% go to the first, rest to second tag.
    use_first = true
    use_first = [true, true, true, true, false].sample if sample_hosts
    if use_first
      ('<script type="text/javascript" src="' + ENV["PUSH_URL"] + '/client.js"></script>').html_safe
    else
      ('<script type="text/javascript" charset="utf-8" src="http://' + ENV["JUGGERNAUT_HOST"] + ':' + ENV["JUGGERNAUT_PORT"] + '/application.js"></script>').html_safe
    end
  end
end