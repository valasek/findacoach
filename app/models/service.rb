class Service < ApplicationRecord
  belongs_to :user
  has_many :sessions, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
