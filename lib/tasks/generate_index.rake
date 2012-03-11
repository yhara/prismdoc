require 'json'

desc "generate index.json"
task :generate_index => :environment do
  puts Entry.where(library_id: LibraryEntry["_builtin"]).
        map(&:belong_name).to_json
end
