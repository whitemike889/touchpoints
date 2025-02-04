class ServiceProvider < ApplicationRecord
  belongs_to :organization
  has_many :services
  has_many :collections, through: :services

  validates :slug, presence: true

  scope :active, -> { where("inactive ISNULL or inactive = false") }
end
