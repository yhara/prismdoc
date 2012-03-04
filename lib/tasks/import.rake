require 'entry_extractor'

namespace :import do
  task :init_ => :environment do
    Entry.create(name: "Array", fullname: "Array",
                 entry_type: EntryType["class"])
    Entry.create(name: "String", fullname: "String",
                 entry_type: EntryType["class"])
  end

  desc "import entries from bitclust"
  task :entries => :environment do
    RubyApi::EntryExtractor.new.run
  end
end

module RubyApi
  module RakeTaskImport

    def find_or_create_entry(fullname, name, type)
      entry = Entry.where(fullname: fullname).first
      if entry.nil?
        entry = Entry.create!(fullname: fullname, name: name,
                             entry_type: EntryType[type])
        puts "new entry: #{type} #{fullname}"
      end
      entry
    end

    def create_document(entry, body, langname)
      Document.create(entry: entry,
                       language: Language[langname],
                       body: body)
      puts "new document for #{entry.fullname} (#{langname})"
    end

  end
end
