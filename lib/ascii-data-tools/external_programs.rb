module AsciiDataTools
  module ExternalPrograms
    def diff(files)
      IO.popen(diff_command_for(files))
    end
    
    def diff_command_for(files)
      "diff " + files.collect(&:path).join(' ')
    end
    
    def sort(input_file, output_file)
      Kernel.system("sort #{input_file.path} > #{output_file.path}")
    end
    
    def edit_differences(filenames)
      Kernel.system("vimdiff #{filenames.join(' ')}")
    end
  end
end