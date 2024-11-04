class DemoDataResetter
  def initialize(user)
    @user = user
  end

  def reset!
    return unless @user.demo_user?
    ActiveRecord::Base.transaction do
      cleanup_existing_data
      seed_fresh_demo_data
    end
  end

  private

  def cleanup_existing_data
    @user.clients.destroy # will destroy dependant sessions due to dependant:destroy
  end

  def seed_fresh_demo_data
    seed_clients
    seed_sessions
  end

  def seed_clients
    15.times do |i|
      Client.create!(
        user_id: @user.id,
        name: Faker::Name.name,
        email: Faker::Internet.email,
        phone: Faker::PhoneNumber.phone_number,
        notes: Faker::Lorem.paragraph(sentence_count: 12),
        created_at: Faker::Time.between(from: 2.years.ago, to: Time.now),
        updated_at: Faker::Time.between(from: 1.year.ago, to: Time.now)
      )
    end
  end

  def seed_sessions
    @user.clients.each do |client|
      session_count = rand(1..20)
      paid_values = ([ true ] * (session_count * 0.8).round + [ false ] * (session_count * 0.2).round).shuffle

      session_count.times do |i|
        Session.create!(
          client_id: client.id,
          date: Faker::Date.between(from: 30.days.ago, to: Time.now),
          duration: Faker::Number.between(from: 0, to: 2.0),
          notes: Faker::Lorem.paragraph(sentence_count: 12),
          paid: paid_values[i]
        )
      end
    end
  end
end
