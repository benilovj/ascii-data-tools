module AsciiDataTools
  class << self
    def configure(&block)
      record_types.instance_eval(&block)
    end
    
    def record_types
      @record_types ||= RecordType::RecordTypeRepository.new
    end

    def autodiscover
      require 'rubygems'

      configuration_files_from_newest_gem_versions = Gem.find_files('ascii-data-tools/discover.rb').select do |path|
        Gem.latest_load_paths.any? {|load_path| path.include?(load_path)} or not path.include?(Gem.default_dir)
      end

      configuration_files_from_newest_gem_versions.each {|f| load f}
    end
  end  
end