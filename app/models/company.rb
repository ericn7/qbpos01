class Company < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  has_and_belongs_to_many :users

  def intuit_token
    @intuit_oauth_access_token = OAuth::AccessToken.new(
      Intuit::API.get_consumer(AppConfig["intuit_consumer_key"], AppConfig["intuit_consumer_secret"]),
      intuit_access_token,
      intuit_access_secret
    )
  end

  def connected_to_intuit?
    return intuit_access_token && intuit_access_secret
  end

  def ever_connected_to_intuit?
    return realm?
  end

end
