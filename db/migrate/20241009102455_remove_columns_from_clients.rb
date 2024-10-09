class RemoveColumnsFromClients < ActiveRecord::Migration[7.2]
  def change
    remove_column :clients, :company, :string
    remove_column :clients, :position, :string
    remove_column :clients, :hours_delivered, :integer
    remove_column :clients, :hours_ordered, :integer
    remove_column :clients, :archived, :boolean
    remove_column :clients, :coaching_goal, :text
  end
end
