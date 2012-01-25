class CompanyController < ApplicationController
  before_filter :find_company, :except => [:index]

  def index
	@companies = Company.all
  end

  def show
	@render_blue_dot = @company.connected_to_intuit?
	@blue_dot_url = company_proxy_path(@company)
	render :layout => false
  end

  def proxy
	response = @company.intuit_token.get("https://appcenter.intuit.com/api/v1/Account/AppMenu")
	status = response.code
	body = response.body
	render :text => body, :status => status
  end

  def disconnect
	if(@company.connected_to_intuit?)
	  @company.intuit_token.get("https://appcenter.intuit.com/api/v1/Connection/Disconnect")
	  @company.update_attributes(
		:intuit_access_token => nil,
		:intuit_access_secret => nil
	  )
	end
	redirect_to company_path(@company)
  end

  def customers
#	if($redis.exists("intuit:ipp:customers:#{@company.id}"))
#	  @customers = Crack::XML.parse($redis.get("intuit:ipp:customers:#{@company.id}"))
#	  @customers ||= {}
#	  if(@customers["RestResponse"])
#		@customers = @customers["RestResponse"]["Customers"]
#	  end
#	else
	  e = @company.intuit_token.get("https://services.intuit.com/sb/customer/v2/#{@company.realm}")
	  body = e.body

render :text => body
	  
	  $redis.set("intuit:ipp:customers:#{@company.id}", body)
	  b = Crack::XML.parse(body)
	  @customers = b["RestResponse"]["Customers"] || {}
	  
#render :text => @customers
#	end
	@final = []
	
	if(@customers["Customer"])
	  @customers["Customer"].each do |c|
		next unless c["Address"] && c["Address"]["Line1"] && c["Address"]["Line2"]
		if($redis.exists("intuit:ipp:anywhere:company:#{@company.id}:customers:#{c["Id"]}:location"))
		  c["Geolocation"] = Crack::JSON.parse($redis.get("intuit:ipp:anywhere:company:#{@company.id}:customers:#{c["Id"]}:location"))
		else
		  r = Crack::JSON.parse(HTTParty.get("http://maps.googleapis.com/maps/api/geocode/json", :query => { :sensor => false, :address => [c["Address"]["Line2"], c["Address"]["City"],
c["Address"]["CountrySubDivisionCode"], c["Address"]["PostalCode"]].join(" ") }).body)
		  if(r["results"] && r["results"][0] && r["results"][0]["geometry"] && r["results"][0]["geometry"]["location"])
			r = r["results"][0]["geometry"]["location"]
			$redis.set("intuit:ipp:anywhere:company:#{@company.id}:customers:#{c["Id"]}:location", r.to_json)
			c["Geolocation"] = r
		  end
		end
		if(c["Geolocation"])
		  @final << c
		end
	  end
	end
#	render :json => @final
  end

  def reconnect
	render :layout => false
  end

  private
   def find_company
	 @company = Company.find(params[:id])
   end


end
