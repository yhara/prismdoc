module RubyApi
  module ExtractorHelper
    # Logger to console(stdout)
    def clogger
      @clogger ||= begin
        level = Logger.const_get((ENV["LOG_LEVEL"] || "info").upcase)
        Logger.new($stdout).tap{|l| l.level = level}
      end
    end
  end
end
