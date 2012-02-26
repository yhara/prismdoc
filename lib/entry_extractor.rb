require 'logger'

module RubyApi
  class EntryExtractor
    def run
      make_library_entries
      make_module_entries
    end

    def make_library_entries
      libs = db.libraries.select{|lib|
        not lib.name == "_builtin" and
        not lib.is_sublibrary #TODO
      }
      libs.each do |lib|
        name = lib.name
        logger.debug "creating entry for library #{name}"
        Entry.create!(fullname: name, name: name,
                      entry_type: EntryType["library"])
      end
    end

    def make_module_entries
      builtin = db.libraries.find{|l| l.name == "_builtin"}
      builtin.classes.each do |c|
        case c.type
        when :class, :module
          logger.debug "creating entry for #{c.type} #{c.name}"
          Entry.create!(fullname: c.name, name: c.name,
                        entry_type: EntryType[c.type.to_s])
        else
          logger.info "skipping #{c.type} #{c.name}"
        end
      end
    end

    private
    def db
      @db ||= begin
        dblocation = URI.parse("file://#{DocumentSource.bitclust_db}")
        BitClust::MethodDatabase.connect(dblocation)
      end
    end

    def logger
      Logger.new($stdout)
    end
  end
end
