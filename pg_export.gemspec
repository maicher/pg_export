# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pg_export/version'

Gem::Specification.new do |spec|
  spec.name          = 'pg_export'
  spec.version       = PgExport::VERSION
  spec.authors       = ['Krzysztof Maicher']
  spec.email         = ['krzysztof.maicher@gmail.com']

  spec.summary       = 'CLI for creating and exporting PostgreSQL dumps to FTP.'
  spec.description   = "CLI for creating and exporting PostgreSQL dumps to FTP.\
                        Can be used for backups or synchronizing databases between production and development environments."
  spec.homepage      = 'https://github.com/maicher/pg_export'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = ['pg_export']
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.2.0'

  spec.add_dependency 'cli_spinnable', '~> 0.2'
  spec.add_dependency 'dry-system', '~> 0.10.0'
  spec.add_dependency 'dry-transaction', '~> 0.13.0'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'pg', '~> 0.21'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rubocop', '~> 0.59.2'
end
