begin
  $LOAD_PATH.unshift "../bitclust/lib/"
  require 'bitclust'
  class BitClust::TerminalView
    # Quick hack to force using utf-8
    def convert(string); string.encode("utf-8"); end

    def puts(*args)
      strs = *args.map{|arg| convert(arg)}
      @buf ||= []
      @buf.concat strs
    end
    attr_reader :buf
  end
rescue LoadError
  # on heroku
  puts "WARNING: bitclust not installed"
end

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
      case entry.kind
      when "library"
        body = extract_library(entry.fullname)
      when "class", "module"
        body = extract_module(entry.fullname)
      when "instance_method", "class_method"
        body = extract_method(entry.fullname)
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
        orig = @yard_extractor.extract_module(name)
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
      def extract_library(name)
        lib = db.libraries.find{|l| l.name == name}
        raise ArgumentError, "library #{name} not found" unless lib

        lib.source
      end

      def extract_module(name)
        with_view{|v|
          v.show_class db.search_classes(name)
          v.buf.join
        }
      end

      def extract_method(name)
        raise
      end

      private
      def db
        @db ||= begin
          dblocation = URI.parse("file:///Users/yhara/.rurema/db/1.9.3/")
          BitClust::MethodDatabase.connect(dblocation)
        end
      end

      def with_view(&block)
        compiler = BitClust::Plain.new
        yield BitClust::TerminalView.new(compiler,
                                         describe_all: false,
                                         line: false,
                                         encoding: nil)
      end
    end

  end
end
