module ActionView
  class Base
    def self.field_error_proc
      Proc.new { |html_tag, instance|  "<span class=\"fieldWithErrors\">#{html_tag}</span>" }
    end
  end
end


