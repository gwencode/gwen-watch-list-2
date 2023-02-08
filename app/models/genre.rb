class Genre < ApplicationRecord
  has_many :movies

  validates :name, :api_id, presence: true
end
