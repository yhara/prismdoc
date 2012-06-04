require 'rdoc_helper.rb'

class Paragraph < ActiveRecord::Base
  belongs_to :language
  belongs_to :original, class_name: "Paragraph"

  validates :language_id, presence: true

  attr_accessible :body

  after_update :update_document_translated

  def documents
    @documents ||= Document.where("paragraph_id_list LIKE '% ? %'", self.id)
  end

  def translated?
    !!body
  end

  def text
    body or original.body
  end

  def html
    RubyApi::RDocHelper.html(self.text)
  end

  private

  def update_document_translated
    self.documents.each(&:update_translated)
  end
end
