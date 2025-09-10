class Avo::Resources::UserProfile < Avo::BaseResource
  self.includes = [ :user ]
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :user_id, as: :number
    field :full_name, as: :text
    field :website, as: :text
    field :bio, as: :textarea
    field :phone, as: :text
    field :username, as: :text
    field :photo, as: :file
    field :user, as: :belongs_to
  end
end
