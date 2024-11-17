class Movie < ApplicationRecord
  has_many :bookmarks, dependent: :destroy
  has_many :lists, through: :bookmarks

  validates :title, :overview, presence: true, uniqueness: true
end
