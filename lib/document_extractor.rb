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
