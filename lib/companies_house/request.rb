module CompaniesHouse
  class Request

    BASE_URI = 'http://data.companieshouse.gov.uk/doc/company/'

    # White list of allowed prefixes for companies house numbers.
    # 1st line is English and Welsh prefixes
    # 2nd line is Scottish prefixes
    # 3rd line is Northen Irish prefixes
    # \d\d is the default prefix in regex notation.
    ALLOWED_PREFIXES = %w(AC BR FC GE IP LP OC RC SE ZC
                          SC SA SF SL SZ SP SO SR
                          NI NA NF NL NZ NP NO NR
                          \d\d)

    # Don't call this directly. Instead, use CompaniesHouse.lookup "01234567"
    def initialize(registration_number)
      @registration_number = validate(registration_number)
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

      # 0-pad 5 or 7 digit registration number
      if number.match /(\D{2})(\d{5})$/
        number = $1 + $2.rjust(6,"0")
      elsif number.match /(\d{7}$)/
        number = number.rjust(8, "0")
      end

      companies_house_regex = Regexp.
        new("\\A(#{ALLOWED_PREFIXES * '|'})\\d{6}\\z")

      msg = "#{number} is not a valid UK company registration number"
      raise InvalidRegistration.new(msg) unless number =~ companies_house_regex

      number
    end
  end
end
