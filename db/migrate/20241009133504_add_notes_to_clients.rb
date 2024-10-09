class AddNotesToClients < ActiveRecord::Migration[7.2]
  def change
    add_column :clients, :notes, :string
  end
end
