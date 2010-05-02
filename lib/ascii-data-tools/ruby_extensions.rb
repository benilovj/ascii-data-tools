if RUBY_VERSION =~ /1[.]9/
  module Enumerable
    def enum_with_index
      map.with_index
    end
  end
end