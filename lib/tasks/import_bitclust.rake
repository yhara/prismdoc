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

module RubyApi
  class RakeTaskImportBitClust
    include RakeTaskImport

    # code taken from bitclust/searcher.rb

    def db
      dblocation = URI.parse("file:///Users/yhara/.rurema/db/1.9.3/")
      BitClust::MethodDatabase.connect(dblocation)
    end

    def make_view
      compiler = BitClust::Plain.new
      yield BitClust::TerminalView.new(compiler,
                                       describe_all: false,
                                       line: false,
                                       encoding: nil)
    end

    def pat(*args)
      BitClust::MethodNamePattern.new(*args)
    end

    def pre(buf)
      "<pre>#{buf.join("\n")}</pre>" 
    end

    def make_class_doc(class_name)
      make_view{|v|
        entry = find_or_create_entry(class_name, class_name, "class")

        v.show_class db.search_classes(class_name)
        body = pre(v.buf)
        create_document(entry, body, "Japanese")
      }
    end

    # typesym - "." or "#"
    def method_names(class_name, typesym)
      db.search_methods(pat(class_name, typesym)).records.map{|r|
        r.specs.first.method
      }
    end

    def make_methods(class_name, typesym)
      method_names(class_name, typesym).each do |name|
        entry = find_or_create_entry([class_name, typesym, name].join,
                                     name, "class")

        make_view{|v|
          v.show_method db.search_methods(pat(class_name, typesym, name))
          body = pre(v.buf)
          create_document(entry, body, "Japanese")
        }
      end
    end

    def import_class(class_name)
      make_class_doc(class_name)
      make_methods(class_name, ".")
      make_methods(class_name, "#")
    end

  end
end

namespace :import do
  desc "import documents from bitclust (lang: ja)"
  task :bitclust => :environment do
    op = RubyApi::RakeTaskImportBitClust.new

    op.import_class("Array")
    op.import_class("String")
    op.import_class("Hash")
    op.import_class("Regexp")
    op.import_class("Symbol")
  end
end
