class Paragraph < ActiveRecord::Base
  belongs_to :language
  belongs_to :original, class_name: "Paragraph"

  validates :language_id, presence: true

  attr_accessible :body

  def documents
    @documents ||= Document.where("paragraph_id_list LIKE '% ? %'", self.id)
  end

  def translated?
    !!body
  end

  def text
    body or original.body
  end
end
