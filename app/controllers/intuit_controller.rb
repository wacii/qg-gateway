class IntuitController < ApplicationController
  def gateway; end

  def oauth
    result = oauth_client.exchange_code_for_tokens(params[:code], params[:state])
    current_user.update_attributes(
      realm_id: params[:realmId],
      access_token: result['result_token'],
      access_token_expires_in: result['expires_in'],
      refresh_token: result['refresh_token'],
      refresh_token_expires_in: result['x_refresh_token_expires_in']
    )
    redirect_to root_path
  end
end
