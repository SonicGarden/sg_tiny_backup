## [Unreleased]

## [0.6.0] - 2022-10-27
- Invoke tar command with only existing files and raise BackupWarning after the backup finished.

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
