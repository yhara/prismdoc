class Document < ActiveRecord::Base
  belongs_to :entry
  belongs_to :language

  validates :entry_id, presence: true,
                       uniqueness: {
                         scope: :language_id,
                         message: "already has a Document for the language"
                       }
  validates :language, presence: true
end

