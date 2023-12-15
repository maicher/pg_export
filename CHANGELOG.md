### 1.0.0 - 2023.12.15
- Make it compatible with Ruby 3.0
- Change configuration envs:
  - BACKUP_FTP_HOST -> PG_EXPORT_GATEWAY_HOST
  - BACKUP_FTP_USER -> PG_EXPORT_GATEWAY_USER
  - BACKUP_FTP_PASSWORD -> PG_EXPORT_GATEWAY_PASSWORD
  - DUMP_ENCRYPTION_KEY -> PG_EXPORT_ENCRYPTION_KEY
- Drop Ruby 2.3 support
- Add SSH option
- Add `encryption_algorithm` option
- All command line options has now their equivalents in ENVs (and vice-versa)
- Remove dry libraries dependencies
- In case of failure bin/pg_export now returns exit value 1
- Improve performance
- Improve error handling

### 0.7.7 - 2020.09.07

- Upgrade dry-initializer

### 0.7.6 - 2020.09.05

- Upgrade dry-types, dry-struct dry-system

### 0.7.0 - 2018.10.18

- Change required ruby version from 2.2.0 to 2.3.0.
- Refactor architecture to be more functional using dry-system
- Use tty for interactive CLI (instead of cli_spinnable)
- Improve configuration parsing
- Add -m option for muting log messages
- Make log messages more verbose

### 0.6.1 - 2017.08.20

- Change required ruby version from 2.1.0 to 2.2.0.

### 0.6.0 - 2017.08.18

- Improve internal architecture

### 0.5.1 - 2017.03.31

- Simplify Dump entity design
- Fix docs

### 0.5.0 - 2017.03.11

- Add restriction on DUMP_ENCRYPTION_KEY, to be exactly 16 characters length
- Make interactive mode more verbose by adding more messages
- Fix concurrently opening ftp connection
- Add closing ftp connection while importing dump in interactive mode
- Fix Cipher deprecation warning
- Fix typos
- Improve code architecture
