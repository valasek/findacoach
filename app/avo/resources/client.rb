class Avo::Resources::Client < Avo::BaseResource
  self.includes = [ :user, :sessions ]
  self.title = :name
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :user, as: :belongs_to
    field :name, as: :text
    field :email, as: :text
    field :phone, as: :text
    field :notes, as: :text
    field :sessions, as: :has_many
  end
end
