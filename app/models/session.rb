class Session < ApplicationRecord
  belongs_to :client

  default_scope { order(:date) }

  validates :date, presence: true
  validates :duration, presence: true, numericality: { greater_than_or_equal_to: 0.0, less_than_or_equal_to: 12.0, step: 0.5 }
  validates :paid, inclusion: { in: [ true, false ] }
end
