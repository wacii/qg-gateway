class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :rememberable,
         :trackable,
         :validatable

  def tokens
    {
      access_token: access_token,
      expires_at: access_token_expires_at,
      refresh_token: refresh_token
    }
  end
end
