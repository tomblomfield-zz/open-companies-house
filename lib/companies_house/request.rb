module CompaniesHouse

  class Request

    BASE_URI = 'http://data.companieshouse.gov.uk/doc/company/'

    # Don't call this directly. Instead, use CompaniesHouse.lookup "01234567"
    def initialize(registration_number)
      @registration_number = validate(registration_number)
      @attributes = {}
    end

    def perform
      url = BASE_URI + @registration_number + ".json"
      response = with_caching { Faraday.get(url) }
      Response.new(response)
    end

    private

    # Use cache if configured
    def with_caching(&block)
      args = CompaniesHouse.cache_args || {}
      cache = CompaniesHouse.cache
      cache ? cache.fetch(@registration_number, args, &block) : yield
    end

    def validate(number)
      number = number.to_s.strip # remove whitespace

      number = "0" + number if number.length == 7 # 0-pad for luck

      msg = "#{number} is not a valid UK company registration number"
      raise InvalidRegistration.new(msg) unless number =~ /\A[0-9]{8}\z/

      number
    end
  end
end