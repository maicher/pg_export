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

    SYNOPSIS
      pg_export DATABASE [OPTION..]
      pg_export --interactive DATABASE [OPTION..]

    EXIT VALUES
      0 - Success
      1 - Error

    ARGUMENTS
      DATABASE - database name to export (when default mode)
               - phrase to filter database dumps by (when interactive mode)

    OPTIONS
      -g, --gateway GATEWAY      Allowed values: ftp, ssh. Default: ftp. Credentials need to be set via ENVs
      -U, --user USER            Gateway (ftp or ssh) user
      -H, --host HOST            Gateway (ftp or ssh) host
      -P, --password PASSWORD    Gateway (ftp or ssh) password
      -d, --database DATABASE    In plain mode: database name to export;
                                 In interactive mode: phrase to filter by
      -e, --encryption_key KEY   Dumps will be SSL encrypted using this key. Should have exactly 16 characters
      -a, --algorithm ALGORITHM  Encryption cipher algorithm (default: AES-128-CBC);
                                 For available option see `$ openssl list -cipher-algorithms`
      -k, --keep KEEP            Number of dump files to keep on FTP (default: 10)
      -s, --ssh                  Same as "--gateway ssh". When set, the --gateway option is ignored
      -f, --ftp                  Same as "--gateway ftp". When set, the --gateway option is ignored
      -t, --timestamped          Prepends log messages with timestamps
      -m, --muted                Mutes log messages. When set, the -t option is ignored. Prints message only on error
      -i, --interactive          Interactive mode, for importing dumps. Whan set, the -t and -m options are ignored
      -w, --welcome              Try connecting to the gateway (FTP or SSH) to verify the connection and exit
      -c, --configuration        Print the configuration and exit
      -v, --version              Print version
      -h, --help                 Print this message and exit

    ENV
      Each of the above options can be also set using enviromental variables.
      Use full option names prepending with PG_EXPORT_ phrase.
      Command line options takes precedence over the ENVs.

      Eg. below two commands are equivalent:
        pg_export -s -U user -H host database_name -k 10

      Is equivalent to:
        export PG_EXPORT_GATEWAY_USER=user
        export PG_EXPORT_GATEWAY_HOST=host
        export PG_EXPORT_KEEP=20
        pg_export -s database_name -k 10

## How to start

__Step 1.__ Prepare ENV variables.

    /* FTP storage for database dumps. */
    PG_EXPORT_GATEWAY_HOST=yourftp.example.com
    PG_EXPORT_GATEWAY_USER=user
    PG_EXPORT_GATEWAY_PASSWORD=password

    /* Encryption key should have exactly 16 characters. */
    /* Dumps will be SSL(AES-128-CBC) encrypted using this key. */
    PG_EXPORT_ENCRYPTION_KEY=1234567890abcdef

__Step 2.__ Print the configuration to verify if env variables has been loaded properly.

    $ pg_export --configuration
    => encryption_key k4***
       gateway_host yourftp.example.com
       gateway_user your_gateway_user
       gateway_password
       logger_format plain
       keep_dumps 10
       ....

__Step 3.__ Try connecting to FTP to verify the connection.

    $ pg_export --gateway ftp --welcome
    => 230 User your_ftp_user logged in

__Step 4.__ Perform database export.

    $ pg_export -d your_database -k 5
    => Dump database your_database to database_name (1.36MB)
       Encrypt database_name_20181016_121314 (1.34MB)
       Connect to yourftp.example.com
       Upload database_name_20181016_121314 (1.34MB) to yourftp.example.com
       Close FTP

## How to restore a dump?

Run interactive mode and follow the instructions:

    pg_export [-d database_name] -i

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/maicher/pg_export. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
