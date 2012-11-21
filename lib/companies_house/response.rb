module CompaniesHouse

  class Response

    attr_reader :attributes

    def initialize(response)
      check_for_errors(response)
      parse_response(response)
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

    private

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
      body = response.body.encode("UTF-8", "ISO-8859-1")
      data = JSON.parse(body)
      @attributes = data["primaryTopic"]
    rescue JSON::ParserError=> e
      error_msg = "Companies house is having problems: #{response.body}"
      raise ServerError.new(error_msg)
    end
  end
end
