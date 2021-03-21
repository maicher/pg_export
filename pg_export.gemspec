# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pg_export/version'

Gem::Specification.new do |spec|
  spec.name          = 'pg_export'
  spec.version       = PgExport::VERSION
  spec.authors       = ['Krzysztof Maicher']
  spec.email         = ['krzysztof.maicher@gmail.com']

  spec.summary       = 'CLI for exporting/importing PostgreSQL dumps via FTP/SSH.'
  spec.description   = "CLI for exporting/importing PostgreSQL dumps via FTP/SSH.\
                        Can be used for backups or synchronizing databases between production and development environments."
  spec.homepage      = 'https://github.com/maicher/pg_export'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/}) }
  spec.executables   = ['pg_export']
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.3.0'

  spec.add_dependency 'dry-initializer', '~> 3.0'
  spec.add_dependency 'dry-types', '~> 1.0'
  spec.add_dependency 'dry-struct', '~> 1.0'
  spec.add_dependency 'dry-system', '~> 0.18'
  spec.add_dependency 'dry-transaction', '~> 0.13'
  spec.add_dependency 'bcrypt_pbkdf'
  spec.add_dependency 'ed25519'
  spec.add_dependency 'net-ssh'
  spec.add_dependency 'net-scp'
  spec.add_dependency 'tty-prompt'
  spec.add_dependency 'tty-spinner'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'pg', '~> 0.21'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rubocop', '~> 0.59.2'
end
