class Converter
def convert_to_utf8 (new_value)
  begin
    # Try it as UTF-8 directly
    cleaned = new_value.dup.force_encoding('UTF-8')
    unless cleaned.valid_encoding?
      # Some of it might be old Windows code page
      cleaned = new_value.encode( 'UTF-8', 'Windows-1252' )
    end
    new_value = cleaned
  rescue EncodingError
    # Force it to UTF-8, throwing out invalid bits
    new_value.encode!( 'UTF-8', invalid: :replace, undef: :replace )
  end
end
end