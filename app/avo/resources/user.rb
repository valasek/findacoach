class Avo::Resources::User < Avo::BaseResource
  self.includes = [ :user_profile, :clients, :sessions ]
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :email, as: :text
    field :demo_user, as: :boolean
    field :provider, as: :text
    field :uid, as: :text
    field :clients, as: :has_many
    field :sessions, as: :has_many, through: :clients
    field :user_profile, as: :has_one
  end
end
