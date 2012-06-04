require 'json'

desc "generate index.json"
task :generate_index => :environment do
  version = Version[ENV["VERSION"]]
  puts Entry.where(library_id: LibraryEntry["_builtin", version].id)
            .map(&:belong_name).to_json
end
