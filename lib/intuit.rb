module Intuit
  module API
    def self.get_consumer(key, secret)
      @consumer = OAuth::Consumer.new(key, secret, {
        :site                 => "https://oauth.intuit.com",
        :request_token_path   => "/oauth/v1/get_request_token",
        :authorize_path       => "/oauth/v1/get_access_token",
        :access_token_path    => "/oauth/v1/get_access_token"
      })
    end
    
    def self.get_request_tokens(key, secret)
      get_consumer(key, secret).get_request_token
    end
    
    def self.authorize_url(token, returl = "")
      returl = returl && !returl.empty? ? "&oauth_callback=#{CGI.escape(returl)}" : ""
      return "https://appcenter.intuit.com/Connect/Begin?oauth_token=#{token}#{returl}"
    end
    
    def self.parse_response(request)
      resp = (request.code.to_i >= 200 && request.code.to_i < 300 && request.body) ? Crack::XML.parse(request.body) : {}
      return ((resp["RestResponse"] && resp["RestResponse"]["Error"]) || resp["FaultInfo"]) ? nil : resp
    end
    
    def self.token_get(token, url)
      begin
        return parse_response(token.get(url))
      rescue => e
        return nil
      end
    end

    private
      def self.hash_from_uri(uri)
        hash = {}
        uri.split("&").each do |e|
          parts = e.split("=")
          hash[parts[0]] = parts[1]
        end
        hash
      end
            
  end
end
