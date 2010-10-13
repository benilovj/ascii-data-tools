require 'terminal-table/import'

module AsciiDataTools
  class RecordTypesConfigurationPrinter
    def initialize(presenter)
      @presenter = presenter
    end
    
    def summary
      table do |t|
        t.headings = @presenter.headings
        @presenter.record_type_summaries.each {|summary| t << summary}
      end.to_s
    end
        
    class << self
      def for_record_types(record_types)
        new(RecordTypesConfigurationPresenter.new(record_types))
      end
    end
  end
  
  class RecordTypesConfigurationPresenter
    def initialize(record_types)
      @record_types = record_types
    end
    
    def headings
      ["type name", "total length", "constraints", "normalised fields"]
    end
    
    def record_type_summaries
      @record_types.sort_by {|record_type| record_type.total_length_of_fields}.inject([]) do |summaries, record_type|
        summaries << [record_type.name, record_type.total_length_of_fields, record_type.constraints_description, record_type.names_of_normalised_fields]
      end
    end
  end  
end