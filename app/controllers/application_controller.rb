class ApplicationController < ActionController::Base
  def oauth_client
    @oauth_client ||= IntuitClient.new
  end
end
