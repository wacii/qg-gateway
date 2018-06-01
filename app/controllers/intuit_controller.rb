class IntuitController < ApplicationController
  def gateway; end

  def oauth
    result = oauth_client.exchange_code_for_tokens(params[:code], params[:state])
    current_user.update_attributes(
      realm_id: params[:realmId],
      access_token: result['result_token'],
      access_token_expires_at: DateTime.new + result['expires_in'],
      refresh_token: result['refresh_token'],
      refresh_token_expires_at: DateTime.new + result['x_refresh_token_expires_in']
    )
    redirect_to root_path
  end

  def revoke
    oauth_client.revoke_tokens(current_user.refresh_token)
    current_user.update_attributes(
      realm_id: nil,
      access_token: nil,
      access_token_expires_at: nil,
      refresh_token: nil,
      refresh_token_expires_at: nil
    )
    flash[:notice] = "Your account is no longer connected to Intuit"
    redirect_to root_path
  end
end
