class HomeController < ApplicationController
  def index
    redirect_to new_user_session_path unless user_signed_in?
    @authorization_endpoint = oauth_client.authorization_endpoint
  end
end