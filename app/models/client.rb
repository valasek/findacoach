class Client < ApplicationRecord
  belongs_to :user

  validates :user, :name, presence: true
  validates :email, :phone, uniqueness: true
  validates :email, presence: true, unless: :phone?
  validates :phone, presence: true, unless: :email?
  validates :email, length: { maximum: 254 }
  validates :name, length: { in: 2..128 }
end
