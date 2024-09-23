class Client < ApplicationRecord
  belongs_to :user

  scope :archived, -> { where(archived: true) }
  scope :unarchived, -> { where(archived: false) }

  attribute :archived, default: -> { false }
  attribute :hours_ordered, default: -> { 0 }
  attribute :hours_delivered, default: -> { 0 }

  validates :user, :name, presence: true
  validates :email, :phone, uniqueness: true
  validates :email, presence: true, unless: :phone?
  validates :phone, presence: true, unless: :email?
  validates :email, length: { maximum: 254 }
  validates :name, length: { in: 2..128 }
  validates :company, :position, length: { maximum: 128 }
  validates :hours_delivered, :hours_ordered, numericality: { greater_than_or_equal_to: 0, less_than: BigDecimal(10**2) }

  def self.filter_by_archive_status(status)
    case status
    when "archived"
      archived
    when "unarchived"
      unarchived
    else
      all
    end
  end
end
