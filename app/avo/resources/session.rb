class Avo::Resources::Session < Avo::BaseResource
  self.includes = [ :client ]
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :client_id, as: :number
    field :date, as: :date
    field :duration, as: :number
    field :paid, as: :boolean
    field :group, as: :boolean
    field :group_size, as: :number
    field :notes, as: :textarea
    field :client, as: :belongs_to
  end
end
