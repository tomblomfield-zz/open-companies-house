require "active_support/core_ext/string/inflections"
require "ostruct"

module CompaniesHouse

  class Response

    attr_reader :attributes, :struct

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

    def method_missing(sym, *args, &block)
    	if @struct.respond_to?(sym)
    		@struct.send(sym)
    	else
    		super sym, *args, &block
    	end
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
      @struct = build_open_struct(@attributes)
    rescue JSON::ParserError=> e
      error_msg = "Companies house is having problems: #{response.body}"
      raise ServerError.new(error_msg)
    end

    def build_open_struct(hash)
    	hash.each_with_object(OpenStruct.new) do |(key, value), struct|
  			value = build_open_struct(value) if value.is_a?(Hash)
  			struct.send("#{key.underscore}=", value)
    	end
    end
  end
end
