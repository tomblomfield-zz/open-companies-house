require 'spec_helper'

describe CompaniesHouse::Request do

  let(:subject) { CompaniesHouse::Request }

  describe "#new" do
    context "throws an exception" do
      it "with a number that's too short" do
        expect {
          subject.new "123456"
        }.to raise_exception CompaniesHouse::InvalidRegistration
      end

      it "that's too long" do
        expect {
          subject.new "123456789"
        }.to raise_exception CompaniesHouse::InvalidRegistration
      end

      it "that's nil" do
        expect {
          subject.new nil
        }.to raise_exception CompaniesHouse::InvalidRegistration
      end

      it "that contains spaces" do
        expect {
          subject.new "1234 ABC"
        }.to raise_exception CompaniesHouse::InvalidRegistration
      end

      it "that contains non alphanumeric chars" do
        expect {
          subject.new "1234?456"
        }.to raise_exception CompaniesHouse::InvalidRegistration
      end
    end

    it "0-pads 7 digit registration numbers" do
      company = subject.new "7495895"
      company.instance_variable_get(:@registration_number).
        should == "07495895"
    end
  end


  describe "perform" do

    before { @request = subject.new("7495895") }

    it "makes an http request" do
      CompaniesHouse::Response.stubs(:new)
      Faraday.expects(:get).with("http://data.companieshouse.gov.uk/doc/company/07495895.json")
      @request.perform
    end

    it "passes the response to a Response object" do
      stub_response = stub
      CompaniesHouse::Response.expects(:new).with(stub_response)
      Faraday.stubs(:get).returns(stub_response)
      @request.perform
    end

    it "caches the request (if enabled)" do
      cached_response = stub
      cache_stub = stub(fetch: cached_response)
      CompaniesHouse.cache = cache_stub # configure
      CompaniesHouse::Response.expects(:new).with(cached_response)
      @request.perform
    end
  end
end