class IntuitController < ApplicationController
  # TODO this is the sandbox, switch with production based on env
  API_URL = 'https://sandbox-quickbooks.api.intuit.com/'

  def gateway
    # TODO extract and rethink
    return head 401 if current_user.refresh_token.nil?

    token = AccessToken.new(oauth_client, current_user.tokens) do |new_tokens|
      current_user.update_attributes(
        access_token: new_tokens['access_token'],
        access_token_expires_at: Time.new + new_tokens['expires_in'],
        refresh_token: new_tokens['refresh_token'],
        refresh_token_expires_at: Time.new + new_tokens['x_refresh_token_expires_in']
      )
    end

    result =
      case request.request_method
      when 'GET'
        token.get(API_URL + params[:path])
      when 'POST'
        # TODO pass form data
        token.post(API_URL + params[:path], {})
      else
        return head 400
      end
    render json: result

  rescue OAuth2::InvalidGrantError
    head 401
  end

  def oauth
    result = oauth_client.exchange_code_for_tokens(params[:code], params[:state])
    # TODO do you need to get the realmID to the client?
    current_user.update_attributes(
      realm_id: params[:realmId],
      access_token: result['access_token'],
      access_token_expires_at: Time.new + result['expires_in'],
      refresh_token: result['refresh_token'],
      refresh_token_expires_at: Time.new + result['x_refresh_token_expires_in']
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
