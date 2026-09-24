class AddSessionBooking < ActiveRecord::Migration[8.1]
  def change
    create_table :booking_settings do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.boolean :enabled, null: false, default: false
      t.text :ics_url
      t.string :timezone, null: false, default: "UTC"
      t.json :weekly_hours, null: false, default: {}
      t.json :duration_options, null: false, default: [ 30, 60 ]
      t.integer :default_duration, null: false, default: 60
      t.integer :minimum_notice_hours, null: false, default: 24
      t.integer :buffer_minutes, null: false, default: 15
      t.datetime :last_calendar_sync_at
      t.string :calendar_sync_status
      t.string :calendar_sync_error

      t.timestamps
    end

    create_table :booking_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :client, null: true, foreign_key: true
      t.references :session, null: true, foreign_key: true
      t.string :visitor_name, null: false
      t.string :visitor_email, null: false
      t.text :goal, null: false
      t.text :coach_message
      t.datetime :starts_at, null: false
      t.string :visitor_timezone, null: false
      t.integer :duration_minutes, null: false
      t.string :status, null: false, default: "pending"
      t.string :idempotency_key, null: false
      t.datetime :decided_at

      t.timestamps
    end

    add_index :booking_requests, :idempotency_key, unique: true
    add_index :booking_requests, [ :user_id, :status, :starts_at ]

    add_column :sessions, :starts_at, :datetime
    change_column :sessions, :duration, :decimal, precision: 5, scale: 2
    add_index :sessions, :starts_at

    add_index :clients, [ :user_id, :email ], unique: true,
      where: "email IS NOT NULL AND email != ''"
    add_index :clients, [ :user_id, :phone ], unique: true,
      where: "phone IS NOT NULL AND phone != ''"
  end
end
