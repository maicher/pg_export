# PgExport

CLI for exporting Rails Postgres database dump to FTP.

Can be used for backups or synchronizing databases between production and development environments.

## Dependencies

  * Ruby >= 2.1
  * PostgreSQL >= 9.1
  * $ pg_dump

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pg_export'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pg_export

## CLI

    $ pg_export -h

    Usage: pg_export [options]
        -d, --database DATABASE          [Required] Name of the database to export
        -k, --keep [KEEP]                [Optional] Number of dump files to keep locally and on FTP (default: 10)
        -t, --timestamped                [Optional] Enables log messages with timestamps
        -h, --help                       Show this message

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/maicher/pg_export. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
