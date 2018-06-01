require_relative 'oauth2'

class IntuitClient < OAuth2
  def initialize
    super(
      discovery_document_url:
        if Rails.env.production?
          'https://developer.intuit.com/.well-known/openid_configuration/'
        else
          'https://developer.intuit.com/.well-known/openid_sandbox_configuration/'
        end,
      client_id: ENV['INTUIT_CLIENT_ID'],
      client_secret: ENV['INTUIT_CLIENT_SECRET'],
      redirect_uri:
        if Rails.env.production?
          ENV['INTUIT_REDIRECT_URI']
        else
          'http://localhost:3000/intuit/oauth'
        end,
      state: ENV['INTUIT_STATE'],
      scope: 'com.intuit.quickbooks.accounting'
    )
  end
end
