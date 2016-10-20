# PgExport

CLI for creating PostgreSQL dumps and exporting them to FTP.

Can be used for backups or synchronizing databases between production and development environments.

Configurable by env variables and (partially) by command line options.

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
    
    Setting can be verified by running following commands:
        -c, --configuration              Prints the configuration
        -f, --ftp                        Tries connecting to FTP to verify the connection

## How to start

__Step 1.__ Prepare FTP account and put configuration into env variables.

    # /etc/enviranment
    BACKUP_FTP_HOST="yourftp.example.com"
    BACKUP_FTP_USER="user"
    BACKUP_FTP_PASSWORD="password"
    
Password cannot include `#` sign, [more info](http://serverfault.com/questions/539730/environment-variable-in-etc-environment-with-pound-hash-sign-in-the-value).

__Step 2.__ Configure other variables (optional).

    # /etc/environment
    DUMPFILE_DIR="/var/dumps"  # default: "tmp/dumps"
    KEEP_DUMPS=3               # default: 10
    KEEP_FTP_DUMPS=5           # default: 10

__Step 3.__ Print the configuration to verify whether env variables has been loaded.

    $ pg_export --configuration
    => database: 
       dumpfile_dir: /var/dumps
       keep_dumps: 3
       keep_ftp_dumps: 5
       ftp_host: yourftp.example.com
       ftp_user: user
       ftp_password: pass***
       
__Step 4.__ Try connecting to FTP to verify the connection.

    $ pg_export --ftp
    => Connect to yourftp.example.com
       Close FTP
    
__Step 5.__ Perform database export.

    $ pg_export -d your_database
    => Dump your_database to /var/dumps/your_database_20161020_125747 (892.38kB)
       Zip dump your_database_20161020_125747.gz (874.61kB)
       Connect to yourftp.example.com
       Export your_database_20161020_125747.gz to FTP
       Close FTP

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/maicher/pg_export. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
