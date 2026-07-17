class CreditType < ApplicationRecord
  has_many :credits, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
end
