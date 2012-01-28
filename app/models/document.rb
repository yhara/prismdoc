class Document < ActiveRecord::Base
  belongs_to :entry
  belongs_to :language

  #not validates :body
end

