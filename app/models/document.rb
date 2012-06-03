class Document < ActiveRecord::Base
  belongs_to :entry
  belongs_to :language

  validates :entry_id, presence: true, uniqueness: {
    scope: [:language_id],
    message: "already has a Document for the language and version for entry %{value}"
  }
  validates :language_id, presence: true
  validates :translated, format: {
    with: /\A(yes|partially|no)\z/,
    message: "unknown state of translation: %{value}"
  }

  before_create :set_translated

  def original
    Document.where(language_id: Language["en"].id,
                   entry_id: self.entry_id).first
  end

  def paragraphs
    return [] if self.paragraph_id_list.nil?

    @paragraphs ||= self.paragraph_id_list.split.map{|id|
      Paragraph.find(id)
    }
  end

  def update_translated
    new_state = translation_state()
    if new_state != self.translated
      update_attribute("translated", new_state)
    end
  end

  private
  def translation_state
    states = paragraphs.map(&:translated?)
    case 
    when states.empty? then "yes"
    when states.all? then "yes"
    when states.none? then "no"
    else "partially"
    end
  end

  def set_translated
    self.translated = translation_state
  end
end

