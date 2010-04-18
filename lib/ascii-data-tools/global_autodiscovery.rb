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

      configuration_files_from_newest_gem_versions = Gem.find_files('ascii-data-tools/discover.rb').select do |path|
        Gem.latest_load_paths.any? {|load_path| path.include?(load_path)}
      end

      configuration_files_from_newest_gem_versions.each {|f| load f}
    end
  end  
end