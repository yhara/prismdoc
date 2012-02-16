module ApplicationHelper
  def language_options
    pairs = Language.all.map{|l| [l.english_name, l.short_name]}
    Hash[*pairs.flatten]
  end

  def current_language
    current = @language || Language.default
    current.short_name
  end
end
