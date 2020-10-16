require_relative './credentials'
require 'looker-sdk'

module SDK
  def self.create_authenticated_sdk
    LookerSDK::Client.new(
      client_id: Credentials::CLIENT_ID,
      client_secret: Credentials::CLIENT_SECRET,
      api_endpoint: Credentials::API_ENDPOINT,
      connection_options: {ssl: {verify: false}},
      # required for using undocumented endpoints
      user_agent: 'HellTool request_id. '
    )
  end
end



