class CompaniesHouse

  class CompanyNotFound < StandardError
  end

  class InvalidRegistration < StandardError
  end

  class ServerError < StandardError
  end

  BASE_URI = 'http://data.companieshouse.gov.uk/doc/company/'

  # Public API
  #
  # Usage:
  # company = CompaniesHouse.lookup "07495895"
  # => #<CompaniesHouse:0x00000100932870 @registration_number="07495895"... >
  #
  # company["CompanyName"]
  # => "GOCARDLESS LTD"
  #
  def self.lookup(registration_number)
    obj = self.new(registration_number)
    obj.lookup
    obj
  end

  # Return a SIC code from the ugly hash
  #
  # company.sic_code
  # => "62090"
  #
  def sic_code
    if self["SICCodes"] && self["SICCodes"]["SicText"]
      self["SICCodes"]["SicText"].first.split[0]
    end
  end

  # So that you can call attributes on the companies house object:
  # company["CompanyName"]
  def [](key)
    @attributes[key]
  end

  attr_accessor :registration_number

  # Don't call this directly. Instead, use CompaniesHouse.lookup "01234567"
  def initialize(registration_number)
    @registration_number = check_registration(registration_number)
    @attributes = {}
  end

  # perform the HTTP request
  def lookup
    url = BASE_URI + @registration_number + ".json"
    response = Faraday.get(url)
    check_for_errors(response)
    parse_response(response)
  end

  private

  def check_registration(number)
    number = number.to_s.strip # remove whitespace

    number = "0" + number if number.length == 7 # 0-pad for luck

    msg = "#{number} is not a valid UK company registration number"
    raise InvalidRegistration.new(msg) unless number =~ /\A[0-9]{8}\z/

    number
  end

  def check_for_errors(response)
    if response.status == 404
      msg = "Company not found with registration #{@registration_number}"
      raise CompanyNotFound.new(msg)
    end

    unless response.status == 200
      msg = "Companies House Responded with status #{response.status}"
      raise ServerError.new(msg)
    end
  end

  def parse_response(response)
    data = JSON.parse(response.body)
    @attributes = data["primaryTopic"]
  end
end