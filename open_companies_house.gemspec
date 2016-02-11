require File.expand_path('../lib/companies_house/version', __FILE__)

Gem::Specification.new do |gem|
  gem.add_development_dependency 'rspec', '~> 2.9.0'
  gem.add_development_dependency 'mocha', '~> 0.10.5'
  gem.add_development_dependency 'webmock', '~> 1.8.8'

  gem.add_dependency "faraday"
  gem.add_dependency "json"

  gem.name = 'open-companies-house'
  gem.summary = "A wrapper around Companies House Open API"
  gem.version = CompaniesHouse::VERSION.dup
  gem.authors = ['Tom Blomfield']
  gem.email = ['tom@gocardless.com']
  gem.homepage = 'https://github.com/gocardless/open-companies-house'
  gem.require_paths = ['lib']
  gem.files = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- spec/*`.split("\n")
end
