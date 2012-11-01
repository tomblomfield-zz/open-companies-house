require 'spec_helper'

describe CompaniesHouse do

  let(:subject) { CompaniesHouse }

  describe ".lookup" do

    context "throws an exception" do
      it "with a number that's too short" do
        expect {
          subject.lookup "123456"
        }.to raise_exception CompaniesHouse::InvalidRegistration
      end

      it "that's too long" do
        expect {
          subject.lookup "123456789"
        }.to raise_exception CompaniesHouse::InvalidRegistration
      end

      it "that's not numeric" do
        expect {
          subject.lookup "abcdefgh"
        }.to raise_exception CompaniesHouse::InvalidRegistration
      end

      it "that's nil" do
        expect {
          subject.lookup nil
        }.to raise_exception CompaniesHouse::InvalidRegistration
      end
    end

    context "with a valid request" do
      before do
        url = "http://data.companieshouse.gov.uk/doc/company/07495895.json"
        stub_request(:get, url).to_return(
          :body => load_fixture("gocardless.json"),
          :status => 200
        )
      end

      it "0-pads 7 digit registration numbers" do
        company = subject.lookup "7495895"
        company.registration_number.should == "07495895"
      end

      it "loads attributes into the object body" do
        company = subject.lookup "07495895"
        company["CompanyName"].should == "GOCARDLESS LTD"
      end

      it "makes SIC code available as a convenience method" do
        company = subject.lookup "07495895"
        company.sic_code.should == "62090"
      end
    end

    context "with a company that doesn't exist" do
      before do
        url = "http://data.companieshouse.gov.uk/doc/company/12345678.json"
        stub_request(:get, url).to_return(
          :body => "Some bullshit HTML response :-(",
          :status => 404
        )
      end

      it "raises an exception" do
        expect {
          company = subject.lookup "12345678"
        }.to raise_exception CompaniesHouse::CompanyNotFound
      end
    end

    context "when the server is down" do
      before do
        url = "http://data.companieshouse.gov.uk/doc/company/12345678.json"
        stub_request(:get, url).to_return(
          :body => "Oh noes",
          :status => 500
        )
      end

      it "raises an exception" do
        expect {
          company = subject.lookup "12345678"
        }.to raise_exception CompaniesHouse::ServerError
      end
    end
  end
end