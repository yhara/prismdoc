class Version < ActiveRecord::Base
  has_many :documents

  validates :name,   presence: true, uniqueness: true

  def self.current
    # TODO: add column :current
    Version.first
  end

  def self.[](name)
    Version.find_by_name(name)
  end
end
