begin
  $LOAD_PATH.unshift "../bitclust/lib/"
  require 'bitclust'

  # Patch for document_extractor.rb
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
  #puts "WARNING: bitclust not installed"
end

module RubyApi
  module BitClustHelper

    private

    def db(ver)
      @db ||= begin
        dblocation = URI.parse("file://#{DocumentSource.bitclust_db(ver)}")
        BitClust::MethodDatabase.connect(dblocation)
      end
    end

    def with_bitclust_view(&block)
      compiler = BitClust::Plain.new
      view = BitClust::TerminalView.new(compiler,
                                        describe_all: false,
                                        line: false,
                                        encoding: nil)
      yield view
      view.buf.join
    end
  end
end
