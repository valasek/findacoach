class Avo::Resources::User < Avo::BaseResource
  self.includes = [ :user_profile, :clients, :sessions ]
  self.title = :email
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :email, as: :text
    field :demo_user, as: :boolean
    field :provider, as: :text
    field :uid, as: :text, hide_on: :index

    field :confirmed_at, as: :date_time, readonly: true, hide_on: :index
    field :confirmation_sent_at, as: :date_time, readonly: true, hide_on: :index

    field :sign_in_count, as: :number, readonly: true
    field :current_sign_in_at, as: :date_time, readonly: true, hide_on: :index
    field :last_sign_in_at, as: :date_time, readonly: true, hide_on: :index
    field :current_sign_in_ip, as: :text, readonly: true

    field :clients, as: :has_many
    field :sessions, as: :has_many, through: :clients
    field :user_profile, as: :has_one
  end
end
