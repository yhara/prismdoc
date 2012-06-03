require 'entry_extractor'
require 'document_extractor'

namespace :import do
  task :init_ => :environment do
    Entry.create(name: "Array", fullname: "Array",
                 entry_type: EntryType["class"])
    Entry.create(name: "String", fullname: "String",
                 entry_type: EntryType["class"])
  end

  desc "import entries from bitclust (VER=xx)"
  task :entries => :environment do
    raise "VER not specified" unless ENV["VER"]
    RubyApi::EntryExtractor.new(ENV["VER"]).run
  end

  desc "import documents (LANG=xx VER=yy)"
  task :documents => :environment do
    language = Language[ENV["LANG"]]
    language_id = language.id

    version = Version.where(name: ENV["VER"]).first
    if version.nil?
      puts "version #{ENV["VER"]} does not exist. create now? [y/n]"
      if $stdin.gets.chomp == "y"
        version = Version.create!(name: ENV["VER"])
      else
        exit
      end
    end
    version_id = version.id

    extractor = RubyApi::DocumentExtractor.for(language, version)
    Document.transaction do
      Entry.find_each do |entry|
        begin
          puts "creating document for #{entry.type} #{entry.fullname}"
          body = extractor.extract_document(entry).body
          Document.create!(entry_id: entry.id,
                           language_id: language_id,
                           version_id: version_id,
                           body: body)
        rescue Exception => ex
          puts "#{ex.class} occured (entry: #{entry.inspect})"
          raise ex
        end
      end
    end
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
