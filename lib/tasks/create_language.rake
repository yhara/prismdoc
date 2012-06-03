desc "Create documents for new language (LANGUAGE='hu;Hungarian;Magyar')"
task :create_language => :environment do
  if ENV["LANGUAGE"] !~ /(.*);(.*);(.*)/
    puts "Error: specify envvar like LANGUAGE='hu;Hungarian;Magyar'"
    exit
  end
  short_name, english_name, native_name = $1, $2, $3
  language = Language.where(short_name: short_name).first
  language ||= Language.create!(short_name: short_name,
                                english_name: english_name,
                                native_name: native_name)
  p language

  Document.transaction do
    # Note: this iterates over entries of all versions
    Entry.find_each do |entry|
      puts "creating document for #{entry.type} #{entry.fullname}"
      Document.create!(entry: entry,
                       language: language)
    end
  end
end

