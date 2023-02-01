class Cast < ApplicationRecord
  belongs_to :movie
  belongs_to :actor

  validates :movie, uniqueness: { scope: :actor }
end
