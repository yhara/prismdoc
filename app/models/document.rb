class Document < ActiveRecord::Base
  belongs_to :entry
  belongs_to :language

  validates :entry_id, presence: true, uniqueness: {scope: :language_id}
  validates :language, presence: true
  validates :body,     presence: true
end

