class Paragraph < ActiveRecord::Base
  belongs_to :language
  belongs_to :original, class_name: "Paragraph"

  validates :language_id, presence: true

  def documents
    @documents ||= Document.where("paragraph_id_list LIKE '% ? %'", self.id)
  end

  def text
    body or original.body
  end
end
