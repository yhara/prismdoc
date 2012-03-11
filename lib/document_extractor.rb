require 'bitclust_helper'
require 'extractor_helper'

module RubyApi
  class DocumentExtractor
    include ExtractorHelper

    def self.for(language)
      case language.short_name
      when "en" then YardExtractor.new
      when "ja" then BitClustExtractor.new
      else TranslationExtractor.new(language)
      end
    end

    # Not an instance of Document, but acts like them.
    class PseudoDocument
      def initialize(body)
        @body = body
      end
      attr_reader :body
    end

    def extract_document(entry)
      case entry
      when LibraryEntry
        body = extract_library(entry)
      when ModuleEntry
        body = extract_module(entry)
      when MethodEntry
        body = extract_method(entry)
      when ConstantEntry
        body = extract_constant(entry)
      end
      PseudoDocument.new(body)
    end

    class YardExtractor < DocumentExtractor
      def extract_library(entry)
        return "(not yet)"

        path = File.join(DocumentSource.ruby_src, "lib", "#{entry.name}.rb")
        if File.exist?(path)
          File.read(path).lines.grep(/^\s*#/).join("<br/>")
        else
          entry.name
        end
      end

      def extract_module(entry)
        return "(not yet)" if entry.library.name != "_builtin"

        case entry.name
        when "Struct::Tms", /Errno::/ then "no doc available"
        else
          registry[entry.name].docstring
        end
      end

      def extract_method(entry)
        return "(not yet)" if entry.library.name != "_builtin"

        if item = registry[entry.belong_name]
          item.docstring
        else
          clogger.warn("no doc for #{entry.fullname}")
          "(no rdoc entry found)"
        end
      end

      alias extract_constant extract_method

      private
      def registry
        @registry ||= YARD::Registry.load(DocumentSource.yard_cache)
      end
    end

    class TranslationExtractor < DocumentExtractor
      include FastGettext::Translation

      def self.init(short_name)
        @init ||= {}
        @init[short_name] ||= begin
          FastGettext.add_text_domain('yard',
            path: "#{DocumentSource.ruby_src}/locale/",
            type: :po)
          FastGettext.text_domain = 'yard'
          FastGettext.locale = short_name
          true
        end
      end

      def initialize(language)
        self.class.init(language.short_name)
        @yard_extractor = YardExtractor.new
      end

      %w(library module method constant).each do |type|
        class_eval <<-EOD
          def extract_#{type}(entry)
            orig = @yard_extractor.extract_#{type}(entry)
            translate(orig)
          end
        EOD
      end

      private

      def translate(str)
        translated_data = ""

        text = YARD::I18N::Text.new(StringIO.new(str))
        text.translate do |type, *args|
          case type
          when :paragraph
            paragraph, = *args
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

      def extract_library(entry)
        lib = db.libraries.find{|l|
          case entry.name
          when "english" then (l.name == "English")
          when "win32api" then (l.name == "Win32API")
          else l.name == entry.name
          end
        }
        raise ArgumentError, "library #{entry.name} not found" unless lib

        lib.source
      end

      def extract_module(entry)
        with_bitclust_view{|v|
          v.show_class db.search_classes(entry.name)
        }
      end

      def extract_method(entry)
        with_bitclust_view{|v|
          q = BitClust::MethodNamePattern.new(
            entry.module.name,
            (entry == SingletonMethodEntry ? "." : "#"),
            entry.name
          )
          v.show_method db.search_methods(q)
        }
      end

      def extract_constant(entry)
        with_bitclust_view{|v|
          q = BitClust::MethodNamePattern.new(
            entry.module.name, "::", entry.name
          )
          v.show_method db.search_methods(q)
        }
      end
    end

  end
end
