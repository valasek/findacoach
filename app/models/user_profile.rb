class UserProfile < ApplicationRecord
  belongs_to :user

  has_one_attached :photo

  validates :full_name, length: { maximum: 100 }
  validates :bio, length: { maximum: 1000 }
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be valid URL", allow_blank: true }
  validates :phone, format: { with: /\A[\+\d\s\-\(\)\.]+\z/, message: "Invalid phone format" },
                 length: { in: 10..20 },
                 allow_blank: true  # Optional field
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :username, format: {
                  with: /\A[a-zA-Z0-9_-]+\z/,
                  message: "can only contain letters, numbers, hyphens, and underscores" }
  validates :username, length: { minimum: 3, maximum: 30 }

  # Reserved usernames to avoid conflicts with existing routes
  RESERVED_USERNAMES = %w[
    admin api www mail ftp blog help support about contact
    findacoach clients sessions manifest service-worker up
    new edit show create update destroy index dashboard
    login logout signup signin signout register
    coach coaches user users profile profiles
    home search settings account billing
  ].freeze

  validates :username, exclusion: { in: RESERVED_USERNAMES, message: "is reserved and cannot be used" }

  before_validation :generate_username, on: :create
  before_validation :normalize_username
  before_save :normalize_website, :normalize_phone

  def photo_attached?
    photo.attached?
  end

  def display_name
    full_name.presence || user.email.split("@").first
  end

  def normalize_website
    return unless website.present?

    self.website = website.strip.downcase
    self.website = "https://#{website}" unless website.match?(/\Ahttps?:\/\//)
  end

  def normalize_phone
    return unless phone.present?

    self.phone = phone.strip.gsub(/\D/, "") # Remove all non-digit characters
    self.phone = "+#{phone}" unless phone.start_with?("+") # Ensure it starts with +
  end

  def normalize_username
    self.username = username.downcase.strip if username.present?
  end

  def generate_username
    return if username.present?

    # Start with email prefix, clean it up
    base = user.email.split("@").first
                .gsub(/[^a-zA-Z0-9_-]/, "")
                .downcase

    # ensure minimum length
    base = "user#{SecureRandom.hex(3)}" if base.length < 3

    # check reserver words
    base = "#{base}_coach" if RESERVED_USERNAMES.include?(base)

    # Ensure the base meets format requirements after cleaning
    base = ensure_valid_format(base)

    self.username = base

    counter = 1
    while UserProfile.exists?(username: username)
      candidate = "#{base}_#{counter}"
      if candidate.length <= 30 && candidate.match?(/\A[a-zA-Z0-9_-]+\z/)
        self.username = candidate
      else
        # If adding counter makes it too long, truncate base and try again
        truncated_base = base[0...(30 - counter.to_s.length)]
        self.username = "#{truncated_base}_#{counter}"
      end

      counter += 1
      # Prevent infinite loop
      break if counter > 9999
    end
  end

  def ensure_valid_format(base)
    # Remove any characters that don't match the format
    cleaned = base.gsub(/[^a-zA-Z0-9_-]/, "")

    # Ensure it starts with a letter, number, underscore, or hyphen (it should after cleaning)
    # If empty after cleaning, generate a fallback
    if cleaned.empty? || cleaned.length < 3
      "user#{SecureRandom.hex(3)}"
    else
      cleaned
    end
  end

  def to_params
    username
  end

  def coach_url
    Rails.application.routes.url_helpers.coach_homepage_path(username: username)
  end

  def full_coach_url(request)
    "#{request.protocol}#{request.host_with_port}#{coach_url}"
  end
end
