require 'spec_helper'

describe CompaniesHouse::Response do

  let(:subject) { CompaniesHouse::Response }

  context "with a successful http response" do
    before do
      url = "http://data.companieshouse.gov.uk/doc/company/07495895.json"
      stub_request(:get, url).to_return(
        :body => load_fixture("gocardless.json"),
        :status => 200
      )
      @response = subject.new(Faraday.get(url))
    end

    it "loads attributes into the object body" do
      @response["CompanyName"].should == "GOCARDLESS LTD"
    end

    it "makes raw attributes available as well" do
      @response.attributes["CompanyName"].should == "GOCARDLESS LTD"
    end

    it "makes SIC code available as a convenience method" do
      @response.sic_code.should == "62090"
    end

    it "makes attributes accessible as methods on the object body" do
      @response.company_name.should == "GOCARDLESS LTD"
    end

    it "makes nested attributes accessible as chained methods on the object body" do
      @response.reg_address.address_line1.should == "22-25 FINSBURY SQUARE"
    end
  end

  context "with a company that doesn't exist" do
    before do
      @url = "http://data.companieshouse.gov.uk/doc/company/12345678.json"
      stub_request(:get, @url).to_return(
        :body => "Some bullshit HTML response :-(",
        :status => 404
      )
    end

    it "raises an exception" do
      expect {
        subject.new(Faraday.get(@url))
      }.to raise_exception CompaniesHouse::CompanyNotFound
    end
  end

  context "when the server is down" do
    before do
      @url = "http://data.companieshouse.gov.uk/doc/company/12345678.json"
      stub_request(:get, @url).to_return(
        :body => "Oh noes",
        :status => 500
      )
    end

    it "raises an exception" do
      expect {
        subject.new(Faraday.get(@url))
      }.to raise_exception CompaniesHouse::ServerError
    end
  end

  context "when the server returns html" do
    it "raises a companies house server error" do
      http_response = stub('Response')
      http_response.stubs(:body).returns("<html><head></head></html>")
      http_response.stubs(:status).returns(200)

      expect {
        subject.new(http_response)
      }.to raise_error(CompaniesHouse::ServerError)
    end
  end
end
