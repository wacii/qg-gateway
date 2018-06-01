class AddRealmIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :realm_id, :string
  end
end
