# SgTinyBackup

Simply backup PostgreSQL database to S3.

## Dependencies

This gem needs the following softwares.

* [AWS CLI](https://aws.amazon.com/cli/)
* [OpenSSL](https://www.openssl.org/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sg_tiny_backup', 'https://github.com/SonicGarden/sg_tiny_backup'
```

## Usage

Generate your config file to `config/sg_tiny_backup.yml`.
You should modify it according to the comments in it.

```
bundle exec rake sg_tiny_backup:generate
```

Backup your database.

```
bundle exec rake sg_tiny_backup:backup
```

Show backup command.

```
bundle exec rake sg_tiny_backup:command
```

Show decryption command example.

```
bundle exec rake sg_tiny_backup:decryption_command
```

## Error reporting
The backup task raises an error when the backup command fails.
So your bug tracking service (like Bugsnag, Sentry, ...) can catch the error.

TODO: Build a detailed error message

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
