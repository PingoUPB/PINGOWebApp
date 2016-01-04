module EventsHelper
  def display_event_token(event)
    if Event::TOKEN_LENGTH > 4
      event.token.to_s.sub(/^00/, "")
    else
      event.token.to_s
    end
  end
end