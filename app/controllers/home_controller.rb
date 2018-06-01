class HomeController < ApplicationController
  def index
    return redirect_to new_user_session_path unless user_signed_in?
    @authorization_endpoint = oauth_client.authorization_endpoint
    @connected_to_intuit = current_user.refresh_token_expires_at.present? &&
      DateTime.now < current_user.refresh_token_expires_at
  end
end