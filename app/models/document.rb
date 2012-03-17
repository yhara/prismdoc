class Document < ActiveRecord::Base
  belongs_to :entry
  belongs_to :language

  validates :entry_id, presence: true,
                       uniqueness: {
                         scope: [:language_id, :version_id],
                         message: "already has a Document for the language and version"
                       }
  validates :language_id, presence: true
  validates :version_id, presence: true

  def original
    Document.where(language_id: Language["en"].id,
                   version_id: self.version_id,
                   entry_id: self.entry_id).first
  end

  def paragraphs
    return [] if self.paragraph_id_list.nil?

    @paragraphs ||= self.paragraph_id_list.split.map{|id|
      Paragraph.find(id)
    }
  end
end

