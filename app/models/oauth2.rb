require 'base64'
require 'json'
require 'net/http'
require 'uri'

# Authorization code grant implementation
class OAuth2
  def initialize(options = {})
    @discovery_document_url = options[:discovery_document_url]
    @client_id = options[:client_id]
    @client_secret = options[:client_secret]
    @redirect_uri = options[:redirect_uri]
    @scope = options[:scope]
    @state = options[:state]
  end

  def authorization_endpoint
    return @authorization_endpoint unless @authorization_endpoint.nil?

    uri = URI(discovery_document['authorization_endpoint'])
    uri.query = URI.encode_www_form(
      client_id: @client_id,
      state: @state,
      scope: @scope,
      redirect_uri: @redirect_uri,
      response_type: 'code'
    )

    @authorization_endpoint = uri.to_s
  end

  def exchange_code_for_tokens(code, state)
    raise 'Incorrect state' if (state != @state) # TODO: specific error here

    request_tokens(
      grant_type: 'authorization_code',
      code: code,
      redirect_uri: @redirect_uri
    )
  end

  def refresh_tokens(refresh_token)
    request_tokens(
      grant_type: 'refresh_token',
      refresh_token: refresh_token
    )
  end

  def revoke_tokens(refresh_token)
    uri = URI(discovery_document['revocation_endpoint'])
    headers = {
      Accept: 'application/json',
      Authorization: authorization_header,
      :'Content-type' => 'application/x-www-form-urlencoded'
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(uri, headers)
    req.set_form_data(refresh_token: refresh_token)

    http.request(req)
  end

  protected

  def authorization_header
    return @authorization_header unless @authorization_header.nil?

    text = "#{@client_id}:#{@client_secret}"
    @authorization_header = "Basic #{Base64.strict_encode64(text)}"
  end

  def discovery_document
    return @discovery_document unless @discovery_document.nil?

    uri = URI(@discovery_document_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Get.new(uri)
    res = http.request(req)

    @discovery_document = JSON.parse(res.body)
  end

  def request_tokens(params)
    uri = URI(discovery_document['token_endpoint'])
    headers = {
      Accept: 'application/json',
      Authorization: authorization_header,
      :'Content-type' => 'application/x-www-form-urlencoded'
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(uri, headers)
    req.set_form_data(params)

    res = http.request(req)
    JSON.parse(res.body)
  end
end
