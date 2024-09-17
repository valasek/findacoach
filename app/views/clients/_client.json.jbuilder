json.extract! client, :id, :user_id, :name, :email, :phone, :company, :position, :hours_ordered, :hours_delivered, :coaching_goal, :archived, :created_at, :updated_at
json.url client_url(client, format: :json)
