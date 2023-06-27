# SgTinyBackup

Simply backup PostgreSQL/MySQL database and logs to S3.

## Dependencies

This gem needs the following softwares.

* [pg_dump](https://www.postgresql.org/docs/current/app-pgdump.html)
* [mysqldump](https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html)
* [OpenSSL](https://www.openssl.org/)
* [AWS CLI](https://aws.amazon.com/cli/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sg_tiny_backup', github: 'SonicGarden/sg_tiny_backup', tag: 'v0.9.0'
```

## Usage

### Generate your config file to `config/sg_tiny_backup.yml`
You should modify it according to the comments in it.

```
bundle exec rake sg_tiny_backup:generate
```

### Backup your database to S3

```
# backup database
bundle exec rake sg_tiny_backup:backup

# backup logs
bundle exec rake sg_tiny_backup:backup BACKUP_TARGET=log
```

### Backup your database to current directory

```
# backup database
bundle exec rake sg_tiny_backup:backup_local

# backup logs
bundle exec rake sg_tiny_backup:backup_local BACKUP_TARGET=log
```

### Show backup command

```
# show database backup command
bundle exec rake sg_tiny_backup:command

# show log backup command
bundle exec rake sg_tiny_backup:command BACKUP_TARGET=log
```

### Show decryption command example

```
bundle exec rake sg_tiny_backup:decryption_command
```

## Setting logger

Logs are outputted to standard output by default.

You can change the logger if you want.

```ruby
SgTinyBackup.logger = Rails.logger
```

## Error reporting

If `SgTinyBackup.raise_on_error` is true, the backup task raises an error when the backup command fails.
So your bug tracking service (like Bugsnag, Sentry, ...) can catch the error.

```ruby
SgTinyBackup.raise_on_error = true # true by default
```

## How it works
This gem simply generates a command line string like the following and runs it.
The credentials are passed to each command by environment variables.

```
pg_dump --username={USER} --host={HOST} --port={PORT} {DATABASENAME} | \
gzip | \
openssl enc -aes-256-cbc -pbkdf2 -iter 10000 -pass env:SG_TINY_BACKUP_ENCRYPTION_KEY | \
aws s3 cp - s3://{BUCKET}/{PREFIX}{TIMESTAMP}.sql.gz.enc
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SonicGarden/sg_tiny_backup.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
