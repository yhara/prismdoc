require 'bitclust_helper'

module RubyApi
  class DocumentExtractor
    def self.for(language)
      case language.short_name
      when "en" then YardExtractor
      when "ja" then BitClustExtractor
      else TranslationExtractor
      end
    end

    class PseudoDocument
      def initialize(body)
        @body = body
      end
      attr_reader :body
    end

    def extract_document(entry)
      case entry
      when LibraryEntry
        body = extract_library(entry.fullname)
      when ModuleEntry
        body = extract_module(entry.name)
      when MethodEntry
        body = extract_method(entry.fullname)
      when ConstantEntry
        # TODO
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

      def extract_method(name)
        registry[name].docstring
      end

      private
      def registry
        @registry ||= YARD::Registry.load(DocumentSource.yard_cache)
      end
    end

    class TranslationExtractor < DocumentExtractor
      include FastGettext::Translation

      def self.init
        @init ||= begin
          FastGettext.add_text_domain('yard',
            path: "#{DocumentSource.ruby_src}/locale/",
            type: :po)
          FastGettext.text_domain = 'yard'
          FastGettext.locale = 'cp'
          true
        end
      end

      def initialize
        super

        self.class.init
        @yard_extractor = YardExtractor.new
      end

      def extract_module(name)
      self.class.init
        orig = @yard_extractor.extract_module(name)
        Rails.logger.debug([:orig, orig].inspect)
        translate(orig)
      end

      private

      def translate(str)
        translated_data = ""

        text = YARD::I18N::Text.new(StringIO.new(str))
        text.translate do |type, *args|
          case type
          when :paragraph
            paragraph, = *args
            Rails.logger.debug([:paragraph, paragraph].inspect)
            translated_data << _(paragraph)
          when :empty_line
            line, = *args
            translated_data << line
          else
            raise "should not reach here: unexpected type: #{type}"
          end
        end
        translated_data
      end
    end

    class BitClustExtractor < DocumentExtractor
      include BitClustHelper

      def extract_library(name)
        lib = db.libraries.find{|l| l.name == name}
        raise ArgumentError, "library #{name} not found" unless lib

        lib.source
      end

      def extract_module(name)
        with_bitclust_view{|v|
          v.show_class db.search_classes(name)
          v.buf.join
        }
      end

      def extract_method(name)
        raise
      end
    end

  end
end
