class User < ActiveRecord::Base
  has_and_belongs_to_many :companies
  has_many :owned_companies, :class_name => "Company", :foreign_key => "owner_id"

  acts_as_authentic do |c|
    crypto_provider = Authlogic::CryptoProviders::BCrypt
  end
  
  validates_presence_of :first_name, :last_name
  
  def name
    return [first_name, last_name].join(" ")
  end
  
  def connected_to_intuit?
    return (intuit_access_token? && intuit_access_secret? rescue false)
  end
end
