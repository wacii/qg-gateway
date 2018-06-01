Warden::Manager.before_logout do |user, _auth, _opts|
  if user.refresh_token.present?
    IntuitClient.new.revoke_tokens(user.refresh_token)
  end
  user.update_attributes!(
    realm_id: nil,
    access_token: nil,
    access_token_expires_at: nil,
    refresh_token: nil,
    refresh_token_expires_at: nil
  )
end
