class IntuitController < ApplicationController
  def gateway
    if current_user.access_token_expires_at.present? &&
      current_user.access_token_expires_at <= Date.new

      result = oauth_client.refresh_tokens(refresh_token)
      current_user.update_attributes(
        access_token: result['result_token'],
        access_token_expires_at: DateTime.new + result['expires_in'],
        refresh_token: result['refresh_token'],
        refresh_token_expires_at: DateTime.new + result['x_refresh_token_expires_in']
      )
    end

    render json: oauth_client.request(
      current_user.access_token,
      request.request_method,
      params[:path]
    )
  end

  def oauth
    result = oauth_client.exchange_code_for_tokens(params[:code], params[:state])
    current_user.update_attributes(
      realm_id: params[:realmId],
      access_token: result['access_token'],
      access_token_expires_at: DateTime.new + result['expires_in'],
      refresh_token: result['refresh_token'],
      refresh_token_expires_at: DateTime.new + result['x_refresh_token_expires_in']
    )
    flash[:notice] = "Your account is now connected to Intuit"
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
