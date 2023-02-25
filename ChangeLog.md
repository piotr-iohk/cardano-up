## [0.1.3] - 2023-02-25

## Added
 - check if `screen` tool is present on the system before starting node or wallet on Linux/MacOs (#4, #5)

## Removed
 - ability to install version from `master` or specific PR in `cardano-wallet` repository (#5)


## [0.1.2] - 2022-10-15

### Added

 - basic session management (cli sub-command: `ls`, parameter: `--session`) (#3)
 - `ping` sub-command for health-checking running node and wallet (#3)
 - check if port is in use when starting wallet (#3)
 - `--examples` parameter listing common usage examples (#3)
 - ChangeLog.md (#3)

### Removed

 - `node-wallet` sub-command (to start both it is enough to call `cardano-up <env> up`) (#3)

## [0.1.1] - 2022-10-09

### Fixed

 - cardano-up config error (#1)

## [0.1.0] - 2022-10-08

Initial pre-release.
