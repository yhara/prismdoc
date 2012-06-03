require 'rdoc_helper'
require 'bitclust_helper'
require 'extractor_helper'

module RubyApi
  class DocumentExtractor
    include ExtractorHelper

    def self.for(language, version)
      case language.short_name
      when "en" then RDocExtractor.new(version)
      when "ja" then BitClustExtractor.new(version)
      else TranslationExtractor.new(language, version)
      end
    end

    # Not an instance of Document, but acts like them.
    class PseudoDocument
      def initialize(body)
        @body = body
      end
      attr_reader :body
    end

    def initialize(version)
      @ver = version.name
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

    class RDocExtractor < DocumentExtractor
      def initialize(ver)
        @rdoc = RDocHelper.new(ver)
        super
      end

      #Override
      def extract_document(entry)
        case entry
        when LibraryEntry
          body = "(not yet)"
        when ModuleEntry
          body = @rdoc.module_doc(entry.name)
        when SingletonMethodEntry
          body = @rdoc.singleton_method_doc(entry.module.name, entry.name)
        when InstanceMethodEntry
          body = @rdoc.instance_method_doc(entry.module.name, entry.name)
        when ConstantEntry
          body = @rdoc.constant_doc(entry.module.name, entry.name)
        end
        PseudoDocument.new(body)
      end

      private
      def registry
        @registry ||= YARD::Registry.load(DocumentSource.yard_cache(@ver))
      end
    end

    class YardExtractor < DocumentExtractor
      def extract_library(entry)
        return "(not yet)"

        path = File.join(DocumentSource.ruby_src(@ver), "lib", "#{entry.name}.rb")
        if File.exist?(path)
          File.read(path).lines.grep(/^\s*#/).join("<br/>")
        else
          entry.name
        end
      end

      def extract_module(entry)
        return "(not yet)" if entry.library.name != "_builtin"

        if item = registry[entry.name]
          item.docstring
        end
      end

      def extract_method(entry)
        return "(not yet)" if entry.library.name != "_builtin"

        if item = registry[entry.belong_name]
          item.docstring
        end
      end

      alias extract_constant extract_method

      private
      def registry
        @registry ||= YARD::Registry.load(DocumentSource.yard_cache(@ver))
      end
    end

    class TranslationExtractor < DocumentExtractor
      include FastGettext::Translation

      def self.init(short_name)
        @init ||= {}
        @init[short_name] ||= begin
          FastGettext.add_text_domain('yard',
            path: "#{DocumentSource.ruby_src(@ver)}/locale/",
            type: :po)
          FastGettext.text_domain = 'yard'
          FastGettext.locale = short_name
          true
        end
      end

      def initialize(language, version)
        super(version)
        self.class.init(language.short_name)
        @yard_extractor = YardExtractor.new
      end

      %w(library module method constant).each do |type|
        class_eval <<-EOD
          def extract_#{type}(entry)
            orig = @yard_extractor.extract_#{type}(entry)
            orig && translate(orig)
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
        lib = db(@ver).libraries.find{|l|
          case entry.name
          when "english" then (l.name == "English")
          when "win32api" then (l.name == "Win32API")
          else l.name == entry.name
          end
        }
        if lib
          lib.source
        else
          nil
        end
      end

      def extract_module(entry)
        with_bitclust_view{|v|
          v.show_class db(@ver).search_classes(entry.name)
        }
      rescue BitClust::ClassNotFound
        nil
      end

      def extract_method(entry)
        with_bitclust_view{|v|
          q = BitClust::MethodNamePattern.new(
            entry.module.name,
            (entry == SingletonMethodEntry ? "." : "#"),
            entry.name
          )
          v.show_method db(@ver).search_methods(q)
        }
      rescue BitClust::MethodNotFound
        nil
      end

      def extract_constant(entry)
        with_bitclust_view{|v|
          q = BitClust::MethodNamePattern.new(
            entry.module.name, "::", entry.name
          )
          v.show_method db(@ver).search_methods(q)
        }
      rescue BitClust::MethodNotFound
        nil
      end
    end

  end
end
