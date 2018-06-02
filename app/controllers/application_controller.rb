class ApplicationController < ActionController::Base
  skip_forgery_protection
  
  def oauth_client
    @oauth_client ||= IntuitClient.new
  end
end
