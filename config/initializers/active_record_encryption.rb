key_generator = ActiveSupport::KeyGenerator.new(Rails.application.secret_key_base)

ActiveRecord::Encryption.configure(
  primary_key: key_generator.generate_key("active-record-encryption-primary", 32),
  deterministic_key: key_generator.generate_key("active-record-encryption-deterministic", 32),
  key_derivation_salt: key_generator.generate_key("active-record-encryption-salt", 32)
)
