require 'spec_helper'

describe CompaniesHouse do

  let(:subject) { CompaniesHouse }

  describe ".lookup" do
    it "initializes a request" do
      CompaniesHouse::Request.expects(:new).with("12345678").
        returns(stub(perform: true))
      subject.lookup "12345678"
    end

    it "calls perform on the request and returns the response" do
      CompaniesHouse::Request.stubs(:new).with("12345678").
        returns(mock(perform: true))
      subject.lookup "12345678"
    end
  end
end