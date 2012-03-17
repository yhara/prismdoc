module RubyApi
  class TextSplitter
    def self.split(str)
      [].tap{|ret|
        text = YARD::I18N::Text.new(StringIO.new(str))
        text.translate do |type, *args|
          case type
          when :paragraph
            paragraph, = *args
            ret << paragraph
          when :empty_line
            line, = *args
            # do nothing
          else
            raise "should not reach here: unexpected type: #{type}"
          end
        end
      }
    end
  end
end
