class Actor < ApplicationRecord
  has_many :casts, dependent: :destroy
  has_many :movies, through: :casts

  validates :name, presence: true
  validates :name, uniqueness: { scope: :api_id }
  validates :api_id, presence: true, uniqueness: true
end
