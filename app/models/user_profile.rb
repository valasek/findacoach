class UserProfile < ApplicationRecord
  belongs_to :user

  has_one_attached :photo

  validates :full_name, length: { maximum: 100 }
  validates :bio, length: { maximum: 1000 }
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be valid URL", allow_blank: true }
  validates :phone, format: { with: /\A[\+\d\s\-\(\)\.]+\z/, message: "Invalid phone format" },
                 length: { in: 10..20 },
                 allow_blank: true  # Optional field

  before_save :normalize_website, :normalize_phone

  def photo_attached?
    photo.attached?
  end

  def display_name
    full_name.presence || user.email.split("@").first
  end

  def normalize_website
    return unless website.present?

    # Normalize website URL
    self.website = website.strip.downcase
    self.website = "https://#{website}" unless website.match?(/\Ahttps?:\/\//)
  end

  def normalize_phone
    return unless phone.present?

    # Normalize phone number
    self.phone = phone.strip.gsub(/\D/, "") # Remove all non-digit characters
    self.phone = "+#{phone}" unless phone.start_with?("+") # Ensure it starts with +
  end
end
