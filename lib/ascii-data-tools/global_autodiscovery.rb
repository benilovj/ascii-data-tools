module AsciiDataTools
  @@record_types = RecordType::RecordTypeRepository.new
  
  class << self
    def register_record_types(*record_types)
      record_types.inject(@@record_types) {|types, type| types << type; type}
    end

    alias :register_record_type :register_record_types

    def clear_record_types
      @@record_types = []
    end

    def record_types
      @@record_types
    end

    def autodiscover
      require 'rubygems'

      Gem.find_files("ascii-data-tools/discover").each do |f|
        load f
      end
    end
  end  
end