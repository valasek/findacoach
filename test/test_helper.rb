ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    def with_available_slots(slots)
      original_constructor = AvailableSlotFinder.method(:new)
      stub = Struct.new(:slots) do
        def call(**) = slots
        def free?(starts_at:, **) = slots.any? { |slot| slot.starts_at.to_i == starts_at.to_i }
      end
      AvailableSlotFinder.define_singleton_method(:new) { |*| stub.new(slots) }
      yield
    ensure
      AvailableSlotFinder.define_singleton_method(:new, original_constructor)
    end
  end

  class ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
  end
end
