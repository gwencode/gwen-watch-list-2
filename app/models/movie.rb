require 'action_view'

class Movie < ApplicationRecord
  has_many :bookmarks
  has_many :lists, through: :bookmarks
  has_many :casts
  has_many :actors, through: :casts

  validates :title, presence: true, uniqueness: true
  validates :overview, presence: true

  include PgSearch::Model
  pg_search_scope :search_by_title,
                  against: :title,
                  using: { tsearch: { prefix: true }, trigram: { word_similarity: true } }

  include ActionView::Helpers::NumberHelper
  def formatted_budget
    number_with_delimiter(budget, delimiter: ',')
  end

  def formatted_revenue
    number_with_delimiter(revenue, delimiter: ',')
  end
end
