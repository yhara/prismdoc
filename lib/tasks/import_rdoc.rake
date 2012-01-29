require 'rdoc/ri/driver'

module RubyApi
  class RakeTaskImportRdoc
    include RakeTaskImport

    def store
      data_path = File.expand_path("../ruby-1.9.3-p0/.ext/rdoc")

      options = RDoc::RI::Driver.process_args(["-d", data_path])
      ri = RDoc::RI::Driver.new(options)

      ri.stores.find{|store| store.path == data_path}
    end

    def render_method(method)
      name = "foo"

      out = RDoc::Markup::Document.new

      out << RDoc::Markup::Paragraph.new("(from #{store.friendly_path})")

      unless name =~ /^#{Regexp.escape method.parent_name}/ then
        out << RDoc::Markup::Heading.new(3, "Implementation from #{method.parent_name}")
      end
      out << RDoc::Markup::Rule.new(1)

      if method.arglists then
        arglists = method.arglists.chomp.split "\n"
        arglists = arglists.map { |line| line + "\n" }
        out << RDoc::Markup::Verbatim.new(*arglists)
        out << RDoc::Markup::Rule.new(1)
      end

      out << RDoc::Markup::BlankLine.new
      out << method.comment
      out << RDoc::Markup::BlankLine.new

      out.accept(RDoc::Markup::ToHtml.new)
    end

    def import_class(class_name)
      store.class_methods[class_name].each do |name|
        m = store.load_method(class_name, name)
        entry = find_or_create_entry("#{class_name}.#{m.name}", m.name,
                                     "class_method")
        create_document(entry, m, "English")
      end

      store.instance_methods[class_name].each do |name|
        m = store.load_method(class_name, "##{name}")
        entry = find_or_create_entry("#{class_name}##{m.name}", m.name,
                                     "instance_method")
        create_document(entry, render_method(m), "English")
      end
    end
  end
end

namespace :import do
  desc "import documents form rdoc (lang: en)"
  task :rdoc => :environment do
    op = RubyApi::RakeTaskImportRdoc.new
    op.import_class("Array")
    op.import_class("String")
    op.import_class("Hash")
    op.import_class("Regexp")
    op.import_class("Symbol")
  end
end
