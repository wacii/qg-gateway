require 'json'
require 'net/http'
require 'uri'

class AccessToken
  def initialize(client, options = {}, &saveTokens)
    @client = client;

    @token = options[:access_token]
    @expires_at = options[:expires_at]
    @refresh_token = options[:refresh_token]

    @saveTokens = saveTokens
  end

  def expired?
    @expires_at <= Time.new
  end

  def refresh!
    # TODO should this code know how to process the response?
    #   this is different than the initialize code...
    result = @client.refresh_tokens(@refresh_token)

    @token = result['access_token']
    @expires_at = Time.new + result['expires_in']
    @refresh_token = result['refresh_token']

    saveTokens.call(result)
  end

  def get(url)
    refresh! if expired?

    uri = URI(url)
    headers = {
      Accept: 'application/json',
      Authorization: "Bearer #{@token}"
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    req = Net::HTTP::Get.new(uri, headers)
    res = http.request(req)

    if res.kind_of?(Net::HTTPUnauthorized)
      refresh!
      return get(url)
    end

    JSON.parse(res.body)
  end

  def post(url, data = {})
    refresh! if expired?

    uri = URI(url)
    headers = {
      Accept: 'application/json',
      Authorization: "Bearer #{@token}",
      :'Content-type' => 'application/x-www-form-urlencoded'
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    req = Net::HTTP::Post.new(uri, headers)
    req.set_form_data(data)
    res = http.request(req)

    if (res.kind_of?(Net::HTTPUnauthorized))
      refresh!
      return post(url, data)
    end

    JSON.parse(res.body)
  end
end
