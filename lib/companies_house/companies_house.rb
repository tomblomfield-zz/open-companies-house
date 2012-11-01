class CompaniesHouse

  class CompanyNotFound < StandardError
  end

  class InvalidRegistration < StandardError
  end

  class ServerError < StandardError
  end

  class << self

    # Public API
    #
    # Usage:
    # company = CompaniesHouse.lookup "07495895"
    # => #<CompaniesHouse:0x00000100932870 @registration_number="07495895"... >
    #
    # company["CompanyName"]
    # => "GOCARDLESS LTD"
    #
    def lookup(registration_number)
      Request.new(registration_number).perform
    end

    attr_accessor :cache, :cache_args

  end

end