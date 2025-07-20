json.extract! session, :id, :client_id, :date, :duration, :paid, :group, :group_size, :notes, :created_at, :updated_at
json.url session_url(session, format: :json)
