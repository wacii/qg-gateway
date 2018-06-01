class ChangeTokensExpiresFieldsInUsers < ActiveRecord::Migration[5.2]
  def up
    remove_column :users, :access_token_expires_in, :string
    remove_column :users, :refresh_token_expires_in, :string

    add_column :users, :access_token_expires_at, :datetime
    add_column :users, :refresh_token_expires_at, :datetime
  end

  def down
    remove_column :users, :access_token_expires_at, :datetime
    remove_column :users, :refresh_token_expires_at, :datetime

    add_column :users, :access_token_expires_in, :string
    add_column :users, :refresh_token_expires_in, :string
  end
end
