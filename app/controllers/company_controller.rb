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
	  #e = @company.intuit_token.get("https://services.intuit.com/sb/customer/v2/#{@company.realm}")
	  e = @company.intuit_token.post("https://qbo.intuit.com/qbo1/resource/customers/v2/#{@company.realm}")
	  body = e.body

render :xml => body
	  
=begin
	  $redis.set("intuit:ipp:customers:#{@company.id}", body)
	  b = Crack::XML.parse(body)
	  @customers = b["RestResponse"]["Customers"] || {}
	  
#render :text => @customers
#	end
	
#render :text => body

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
=end
  end

  def reconnect
		render :layout => false
  end
	
	def test


		createrecordxml = "
<SalesReceipt xmlns:ns2=\"http://www.intuit.com/sb/cdm/qbo\" xmlns=\"http://www.intuit.com/sb/cdm/v2\"> 
	<Header> 
		<CustomerId>37</CustomerId>  
	</Header> 
	<Line> 
		<Amount>70.00</Amount> 
	</Line>  
</SalesReceipt>
		"

		e = @company.intuit_token.post("https://qbo.intuit.com/qbo1/resource/sales-receipt/v2/#{@company.realm}", createrecordxml, {"Content-Type" => "application/xml", "standalone" => "yes", "encoding" => "UTF-8"})
#e = @company.intuit_token.post("https://qbo.intuit.com/qbo1/resource/sales-receipt/v2/#{@company.realm}")

		body = e.body

		render :xml => body
	
	end
  
  def testold
	
  
  	#e = @company.intuit_token.post("https://qbo.intuit.com/qbo1/resource/customers/v2/#{@company.realm}")
		
#		e = @company.intuit_token.post("https://qbo.intuit.com/qbo1/resource/sales-receipt/v2/#{@company.realm}", :body => 
=begin
		{	:SalesReceipt => {
				:Header => {
					:DocNumber => '99009926',
					:TxnDate  => '2010-10-22',
					:Currency     => 'USD',
					:CustomerId    => '1',
					:ShipDate    => '2011-04-22',
					:TotalAmt => '2500',
					:DiscountAmt => '0'
				},
				:Line => {
					:Desc => 'Keyboards',
					:Amount => '2500',
					:ItemName => 'Pen',
					:UnitPrice => '10',
					:Qty => '2'
				}
			}
		})

"<SalesReceipt xmlns=\"http://www.intuit.com/sb/cdm/qbo\" xmlns=\"http://www.intuit.com/sb/cdm/v2\">
<Header>
<DocNumber>99009926</DocNumber>
<TxnDate>2010-10-22</TxnDate>
<Currency>USD</Currency>
<CustomerId idDomain=\"QBO\">1</CustomerId>
<ShipDate>2011-04-22</ShipDate>
<TotalAmt>2500</TotalAmt>
<DiscountAmt>0</DiscountAmt>
</Header>
<Line>
<Desc>Keyboards</Desc>
<Amount>2500</Amount>
<ItemName>Pen</ItemName>
<UnitPrice>10</UnitPrice>
<Qty>2</Qty>
</Line>
</SalesReceipt>")

		e = @company.intuit_token.post("https://qbo.intuit.com/qbo1/resource/account/v2/#{@company.realm}",
				{ :body => 
						"<Account xmlns:ns2=\"http://www.intuit.com/sb/cdm/qbo\" xmlns=\"http://www.intuit.com/sb/cdm/v2\">
								<Name>Test Account 2</Name>
								<Desc>Test Account</Desc>
								<Subtype>Savings</Subtype>
								<AcctNum>5001</AcctNum>
								<OpeningBalanceDate>2010-05-14</OpeningBalanceDate>
						</Account>",
				:headers => {
						"Content-Type" => "application/xml",
						"standalone" => "yes",
						"encoding" => "UTF-8",
						"xml version" => "1.0"
				}}
		)


	createrecordxml = "
		<Account xmlns:ns2=\"http://www.intuit.com/sb/cdm/qbo\" xmlns=\"http://www.intuit.com/sb/cdm/v2\">
		<Name>Test Account 2</Name>
		<Desc>Test Account 2</Desc>
		<Subtype>Savings</Subtype>
		<AcctNum>5003</AcctNum>
		<OpeningBalanceDate>2010-05-14</OpeningBalanceDate>
		</Account>
	"

			e = @company.intuit_token.post("https://qbo.intuit.com/qbo1/resource/account/v2/#{@company.realm}", createrecordxml, {"Content-Type" => "application/xml", "standalone" => "yes", "encoding" => "UTF-8"})
######################################################

		createrecordxml = "
<Invoice xmlns=\"http://www.intuit.com/sb/cdm/v2\" xmlns:ns2=\"http://www.intuit.com/sb/cdm/qbopayroll/v1\" xmlns:ns3=\"http://www.intuit.com/sb/cdm/qbo\">
		<Header>
				<DocNumber>00010</DocNumber>
				<TxnDate>2010-08-07-07:00</TxnDate>
				<Msg>No Black Ink Pens</Msg>
				<Note>Blue Ink pens only</Note>
				<CustomerId>37</CustomerId>
				<SubTotalAmt>400.00</SubTotalAmt>
				<TotalAmt>400.00</TotalAmt>
				<DueDate>2010-08-16-07:00</DueDate>
				<BillEmail>john_doe@digitalinsight.com</BillEmail>
		</Header>
		<Line>
				<Desc>Pens</Desc>
				<Amount>200.00</Amount>
				<Taxable>true</Taxable>
				<ItemId>4</ItemId>
				<UnitPrice>100</UnitPrice>
				<Qty>4</Qty>
		</Line>
</Invoice>
		"

		e = @company.intuit_token.post("https://qbo.intuit.com/qbo1/resource/invoice/v2/#{@company.realm}", createrecordxml, {"Content-Type" => "application/xml", "standalone" => "yes", "encoding" => "UTF-8"})


####################################################

=end

#d1 = "<?xml version=\"1.0\" encoding=\"utf-8\"?><Account xmlns:ns2=\"http://www.intuit.com/sb/cdm/qbo\" xmlns=\"http://www.intuit.com/sb/cdm/v2\"><Name>Test Account 2</Name><Desc>Test Account</Desc><Subtype>Savings</Subtype><AcctNum>5001</AcctNum><OpeningBalanceDate>2010-05-14</OpeningBalanceDate></Account>"

#e = @company.intuit_token.post("https://qbo.intuit.com/qbo1/resource/account/v2/#{@company.realm}", :body => d1.to_xml )

		e = @company.intuit_token.post("https://qbo.intuit.com/qbo1/resource/account/v2/#{@company.realm}", "<Account xmlns:ns2=\"http://www.intuit.com/sb/cdm/qbo\" xmlns=\"http://www.intuit.com/sb/cdm/v2\"><Name>Test Account </Name><Desc>Test Account</Desc><Subtype>Savings</Subtype><AcctNum>5002</AcctNum><OpeningBalanceDate>2010-05-14</OpeningBalanceDate></Account>", {"Content-Type" => "application/xml", "standalone" => "yes", "encoding" => "UTF-8"})
		
	  body = e.body

		render :text => body
  
  end

  private
   def find_company
	 @company = Company.find(params[:id])
   end


end
