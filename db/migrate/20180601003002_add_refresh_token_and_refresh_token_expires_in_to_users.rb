class AddRefreshTokenAndRefreshTokenExpiresInToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :refresh_token, :string
    add_column :users, :refresh_token_expires_in, :string
  end
end
