class Avo::Resources::Client < Avo::BaseResource
  self.includes = [ :user, :sessions ]
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :user_id, as: :number
    field :name, as: :text
    field :email, as: :text
    field :phone, as: :text
    field :notes, as: :text
    field :user, as: :belongs_to
    field :sessions, as: :has_many
  end
end
