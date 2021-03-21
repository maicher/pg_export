# PgExport

[![Gem Version](https://badge.fury.io/rb/pg_export.svg)](https://badge.fury.io/rb/pg_export)
[![Build Status](https://travis-ci.org/maicher/pg_export.svg?branch=master)](https://travis-ci.org/maicher/pg_export)
[![Code Climate](https://codeclimate.com/github/maicher/pg_export/badges/gpa.svg)](https://codeclimate.com/github/maicher/pg_export)

CLI for creating and exporting PostgreSQL dumps to FTP.

Can be used for backups or synchronizing databases between production and development environments.

Example:

    pg_export --database database_name --keep 5
    
Above command will perform database dump, encrypt it, upload it to FTP and remove old dumps from FTP, keeping newest 5.

FTP connection params and encryption key are configured by env variables.

Features:

- uses shell command `pg_dump` and `pg_restore`
- encrypts dumps by OpenSSL AES-128-CBC
- configurable through env variables
- uses ruby tempfiles, so local dumps are garbage collected automatically
- easy restoring dumps through interactive mode

## Dependencies

  * Ruby >= 2.4 (works with Ruby 3.0)
  * $ pg_dump
  * $ pg_restore

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
        -g, --gateway GATEWAY            [Optional] ssh or ftp (default: ftp)
        -d, --database DATABASE          [Required] Name of the database to export
        -k, --keep [KEEP]                [Optional] Number of dump files to keep on FTP (default: 10)
        -t, --timestamped                [Optional] Enables log messages with timestamps
        -m, --muted                      [Optional] Mutes log messages (overrides -t option)
        -i, --interactive                [Optional] Interactive command line mode - for restoring dumps into databases
        -v, --version                    Show version
        -h, --help                       Show this message

    Setting can be verified by running following commands:
        -c, --configuration              Prints the configuration
        -w, --welcome                    Tries connecting to the gateway (FTP or SSH) to verify the connection


## How to start

__Step 1.__ Prepare ENV variables.

    /* FTP storage for database dumps. */
    PG_EXPORT_GATEWAY_HOST=yourftp.example.com
    PG_EXPORT_GATEWAY_USER=user
    PG_EXPORT_GATEWAY_PASSWORD=password
    
    /* Encryption key should have exactly 16 characters. */
    /* Dumps will be SSL(AES-128-CBC) encrypted using this key. */
    PG_EXPORT_ENCRYPTION_KEY=1234567890abcdef
    
    /* Dumps to be kept on FTP */
    /* Optional, defaults to 10 */
    KEEP_DUMPS=5
    
Note, that variables cannot include `#` sign, [more info](http://serverfault.com/questions/539730/environment-variable-in-etc-environment-with-pound-hash-sign-in-the-value). 

__Step 2.__ Print the configuration to verify if env variables has been loaded properly.

    $ pg_export --configuration
    => {:encryption_key=>"k4***", :gateway_host=>"yourftp.example.com", :gateway_user=>"your_gateway_user",
       :gateway_password=>"pass***", :logger_format=>"plain", :keep_dumps=>2}
       
__Step 3.__ Try connecting to FTP to verify the connection.

    $ pg_export --gateway ftp --welcome
    => 230 User your_ftp_user logged in
    
__Step 4.__ Perform database export.

    $ pg_export -d your_database [-k 5]
    => Dump database your_database to your_database_20181016_121314 (1.36MB)
       Encrypt your_database_20181016_121314 (1.34MB)
       Connect to yourftp.example.com
       Upload your_database_20181016_121314 (1.34MB) to yourftp.example.com
       Close FTP
       
## How to restore a dump?

Run interactive mode and follow the instructions:

    pg_export [-d your_database] -i

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/maicher/pg_export. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
