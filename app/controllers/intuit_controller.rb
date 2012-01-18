class IntuitController < ApplicationController
  before_filter :login_required

  def connect
	consumer = Intuit::API.get_consumer(AppConfig["intuit_consumer_key"], AppConfig["intuit_consumer_secret"])
	token = consumer.get_request_token(:oauth_callback => intuit_callback_url)
	session[:request_token] = token
	redirect_to Intuit::API.authorize_url(token.token)
  end

  def callback
	at = session[:request_token].get_access_token(:oauth_verifier => params[:oauth_verifier])
	session[:request_token] = nil
	if(@company = Company.where(:realm => params["realmId"]).first)
	  @company.update_attributes(:owner => current_user, :intuit_access_token => at.token, :intuit_access_secret => at.secret)
	  if(!@company.users.include?(current_user))
		@company.users << current_user
	  end
	else
	  @company = Company.create(
		:intuit_access_token => at.token,
		:intuit_access_secret => at.secret,
		:realm => params["realmId"],
		:owner => current_user,
		:name => "",
		:is_qbo => params["dataSource"] == "QBO"
	  )
	  @company.users << current_user
	end
	b = Crack::XML.parse(@company.intuit_token.get("https://services.intuit.com/sb/company/v2/availableList").body)
	b = b["RestResponse"]["CompaniesMetaData"]["CompanyMetaData"]
	if(b.is_a?(Hash))
	  name = b
	else
	  name = b.select { |x| x["ExternalRealmId"].to_s == @company.realm.to_s }.first
	end
	if(name)
	  name = name["QBNRegisteredCompanyName"]
	else
	  name = "Untitled"
	end
	@company.name = name
	@company.save
	render :layout => false
  end  
end

