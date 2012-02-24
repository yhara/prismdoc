require 'yard'

module RubyApi
  class DocumentExtractor
    def self.for(language)
      (language.short_name == "en") ?  YardExtractor : BitClustExtractor
    end

    class PseudoDocument
      def initialize(body)
        @body = body
      end
      attr_reader :body
    end

    def extract_document(entry)
      case entry.type
      when "library"
        body = extract_library(entry.fullname)
      when "class", "module"
        body = extract_module(entry.fullname)
      when "instance_method"
      when "class_method"
      when "constant"
      end
      PseudoDocument.new(body)
    end

    class YardExtractor < DocumentExtractor
      def extract_library(name)
        path = File.join(DocumentSource.ruby_src, "lib", "#{name}.rb")
        if File.exist?(path)
          File.read(path).lines.grep(/^\s*#/).join("<br/>")
        else
          name
        end
      end

      def extract_module(name)
        registry[name].docstring
      end

      private
      def registry
        @registry ||= YARD::Registry.load(DocumentSource.yard_cache)
      end
    end

    class BitClustExtractor < DocumentExtractor

      def extract_method

      end
      
    end
  end
end
