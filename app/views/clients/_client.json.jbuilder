json.extract! client, :id, :user_id, :name, :email, :phone, :notes, :created_at, :updated_at
json.url client_url(client, format: :json)
