class String
  SINGLE_QUOTES_TOKEN_REGEXP = /'.*?'/
  
  def split_respecting_single_quotes
    line_without_tokens, tokens = extract_single_quoted_tokens
    line_without_tokens_with_escaped_spaces = line_without_tokens.split.join("~~")
    line_with_tokens_with_escaped_spaces = line_without_tokens_with_escaped_spaces % tokens
    line_with_tokens_with_escaped_spaces.split("~~")
  end
  
  protected
  def extract_single_quoted_tokens(tokens = [])
    return self, tokens unless self =~ SINGLE_QUOTES_TOKEN_REGEXP
    
    string_with_next_token_replaced = self.sub(SINGLE_QUOTES_TOKEN_REGEXP, "%s")
    next_token = self.scan(SINGLE_QUOTES_TOKEN_REGEXP).first
    return string_with_next_token_replaced.extract_single_quoted_tokens(tokens + [next_token])
  end
end

if RUBY_VERSION =~ /1[.]9/
  module Enumerable
    def enum_with_index
      map.with_index
    end
  end
end