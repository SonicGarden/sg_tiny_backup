## [Unreleased]

## [0.10.0] - 2024-03-18

- Fix loading YAML with ERB

## [0.9.0] - 2023-06-27

- Read config/database.yml values as ERB.

## [0.8.0] - 2023-04-13

### Breaking changes

- If log files in `log > files` field are missing, the gem raise BackupFailed.
- If log files are optional, use `optional_files` as YAML key instead of `files`.

## [0.7.0] - 2022-12-16

- MySQL backup support

## [0.6.0] - 2022-10-27

- If log files are missing, invoke tar command with only existing files and raise BackupWarning after the backup finished.

## [0.5.0] - 2022-09-01

### Fixes

- The backup rake task fails if GNU tar exits with code 1

### Breaking changes

- `SgTinyBackup.raise_on_error` is true by default

## [0.4.0] - 2022-08-27

### Features

- Rake tasks use BACKUP_TARGET environment variable

## [0.3.0] - 2022-08-27

### Breaking changes

- Change S3 path
- Log backup filename includes hostname

## [0.2.0] - 2022-08-27

### Features

- Log backup

### Breaking changes

- S3 configuration changed to support log backup

## [0.1.0] - 2022-08-18

- Initial release
