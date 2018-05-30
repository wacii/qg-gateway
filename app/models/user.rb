class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :rememberable,
         :trackable,
         :validatable
end
